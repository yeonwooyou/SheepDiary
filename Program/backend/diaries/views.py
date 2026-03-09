from rest_framework import status
from rest_framework.views import APIView
from rest_framework.generics import GenericAPIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Diary, Emotion, DiaryKeyword
from .serializers import DiarySerializer, DiarySuggestionRequestSerializer
from drf_spectacular.utils import extend_schema, OpenApiExample
from datetime import datetime, timedelta
from django.apps import apps
from collections import OrderedDict

Keyword = apps.get_model("events", "Keyword")

class DiaryCreateView(APIView):
    permission_classes = [IsAuthenticated]
    serializer_class = DiarySerializer

    @extend_schema(
        request=DiarySerializer,
        responses={201: DiarySerializer}
    )

    def get_serializer(self, *args, **kwargs):
        return self.serializer_class(*args, **kwargs)

    def post(self, request):
        # print(request.data)
        serializer = self.get_serializer(data=request.data, context={"request": request})
        if serializer.is_valid():
            emotion = serializer.validated_data.get("emotion", None)
            emotion_id = emotion if emotion is not None else 1
            diary = serializer.save(
                emotion_id_id=emotion_id,
                user=request.user
            )

            # keywords = request.data.get('keywords', [])
            # for keyword_data in keywords:
            #     diary.add_keyword(
            #         keyword_content=keyword_data['content'],
            #         is_selected=keyword_data.get('is_selected', True),
            #         is_auto_generated=keyword_data.get('is_auto_generated', False)
            #     )

            timeline_sent = request.data.get('timeline_sent', [])
            markers = request.data.get('markers', [])
            camera_target = request.data.get('camera_target', [])
            diary.timeline_sent = timeline_sent
            diary.markers = markers
            diary.camera_target = camera_target
            diary.save()

            return Response({"message": "일기가 성공적으로 작성되었습니다."}, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class DiaryByMonthView(APIView):
    permission_classes = [IsAuthenticated]
    serializer_class = DiarySerializer

    @extend_schema(
        responses={
            200: OpenApiExample(
                "일기 조회 성공",
                value={
                    "diaries": [
                        {
                            "date": "2025-05-18",
                            "diary_id": 1,
                            "emotion": "happy",
                            "keywords": ["keyword1", "keyword2"],
                            "emotion_id": 1,
                        }
                    ]
                }
            )
        }
    )

    def get(self, request):
        month = request.query_params.get("month", None)
        if not month:
            return Response({"detail": "month 파라미터를 입력해주세요."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            month_date = datetime.strptime(month, "%Y-%m")
        except ValueError:
            return Response({"detail": "month 형식: 'YYYY-MM'."}, status=status.HTTP_400_BAD_REQUEST)

        start_date = month_date.replace(day=1)
        end_date = (start_date.replace(day=28) + timedelta(days=4)).replace(day=1) - timedelta(days=1)

        diaries = Diary.objects.filter(
            user=request.user, 
            diary_date__range=(start_date, end_date)
        ).order_by("diary_date")  # 날짜 오름차순

        # 날짜별 첫 번째 다이어리만 담기 위한 OrderedDict 사용
        unique_diaries = OrderedDict()
        for diary in diaries:
            key = diary.diary_date.strftime("%Y-%m-%d")
            if key not in unique_diaries:
                keywords = [dk.keyword.content for dk in DiaryKeyword.objects.filter(diary=diary)]
                emotion = diary.emotion_id_id if diary.emotion_id_id else 1
                unique_diaries[key] = {
                    "date": key,
                    "diary_id": diary.diary_id,
                    "emotion": emotion,
                    "keywords": keywords,
                    "emotion_id": emotion,
                }

        return Response({"diaries": list(unique_diaries.values())}, status=status.HTTP_200_OK)

    # def get(self, request):
    #     month = request.query_params.get("month", None)
    #     if not month:
    #         return Response({"detail": "month 파라미터를 입력해주세요."}, status=status.HTTP_400_BAD_REQUEST)

    #     try:
    #         month_date = datetime.strptime(month, "%Y-%m")
    #     except ValueError:
    #         return Response({"detail": "month 형식: 'YYYY-MM'."}, status=status.HTTP_400_BAD_REQUEST)

    #     start_date = month_date.replace(day=1)
    #     end_date = (start_date.replace(day=28) + timedelta(days=4)).replace(day=1) - timedelta(days=1)

    #     diaries = Diary.objects.filter(
    #         user=request.user, 
    #         diary_date__range=(start_date, end_date)
    #     ).order_by("diary_date")  # 날짜 오름차순

    #     diary_dates = sorted(set(diary.diary_date.strftime("%Y-%m-%d") for diary in diaries))

    #     return Response({"diary_dates": diary_dates}, status=status.HTTP_200_OK)
    


class DiaryDetailView(APIView):
    permission_classes = [IsAuthenticated]
    serializer_class = DiarySerializer

    @extend_schema(
        responses={
            200: OpenApiExample(
                "일기 조회 성공",
                value={
                    "diaries": [
                        {
                            "date": "2025-05-18",
                            "diary_id": 1,
                            "emotion": "happy",
                            "keywords": ["keyword1", "keyword2"],
                            "emotion_id": 1,
                        }
                    ]
                }
            )
        }
    )

    def get(self, request, diary_date):
        try:
            # diary_date와 일치하는 첫 번째 다이어리 가져오기
            diary = Diary.objects.filter(diary_date=diary_date).first()
            if not diary:
                return Response({"detail": "해당 날짜의 다이어리가 없습니다."}, status=status.HTTP_404_NOT_FOUND)
            
            # 다이어리 데이터 생성
            keywords = [dk.keyword.content for dk in DiaryKeyword.objects.filter(diary=diary)]
            emotion = diary.emotion_id_id if diary.emotion_id_id else 1
            
            data = {
                "date": diary.diary_date.strftime("%Y-%m-%d"),
                "diary_id": diary.diary_id,
                "emotion": emotion,
                "keywords": keywords,
                "emotion_id": emotion,
                "final_text": diary.final_text,
                # 다른 필드들 추가
            }
            
            return Response(data, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"detail": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    def put(self, request, diary_date):
        try:
            # 날짜와 사용자로 필터링하여 하나의 일기만 가져오도록 수정
            diary = Diary.objects.get(
                diary_date=diary_date,
                user=request.user
            )
        except Diary.DoesNotExist:
            return Response({"message": "'diary_date'에 맞는 일기가 없습니다."}, status=status.HTTP_404_NOT_FOUND)
        except Diary.MultipleObjectsReturned:
            # 같은 날짜에 여러 일기가 있는 경우, 가장 최근에 수정된 일기를 가져옵니다.
            diary = Diary.objects.filter(
                diary_date=diary_date,
                user=request.user
            ).order_by('-updated_at').first()
            if not diary:
                return Response({"message": "'diary_date'에 맞는 일기가 없습니다."}, status=status.HTTP_404_NOT_FOUND)

        content = request.data.get("final_text", None)
        if content is None:
            return Response({"message": "'final_text' 필드를 작성해주세요"}, status=status.HTTP_400_BAD_REQUEST)

        # 추가 필드 처리
        diary.tags = request.data.get('tags', [])
        diary.emotion_id_id = request.data.get('emotion', diary.emotion_id_id)
        diary.timeline_sent = request.data.get('timeline_sent', [])
        diary.markers = request.data.get('markers', [])
        diary.camera_target = request.data.get('cameraTarget', {})

        longitude = request.data.get('longitude', None)
        latitude = request.data.get('latitude', None)
        if longitude is not None:
            diary.longitude = longitude
        if latitude is not None:
            diary.latitude = latitude

        diary.final_text = content
        diary.save()

        return Response({"message": "일기가 수정되었습니다."}, status=status.HTTP_200_OK)


class DiarySuggestionView(GenericAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = DiarySuggestionRequestSerializer

    @extend_schema(
        request=DiarySuggestionRequestSerializer,
        responses={200: DiarySerializer}
    )

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        try:
            validated_data = serializer.validated_data

            event_ids_list = validated_data.get('event_ids_series', [])

            event_ids = [eid for eid in event_ids_list if eid != -1]

            Event = apps.get_model("events", "Event")
            events = Event.objects.filter(event_id__in=event_ids).order_by('time')

            events_data = []
            for event in events:
                event_info = {
                    'id': event.event_id,
                    'place': event.title.split("에서")[1],
                    'emotion': event.event_emotion_id,
                    'keywords': [kw.content for kw in event.keywords.all()],
                    'start_time': event.time
                }
                events_data.append(event_info)

            # from ai_models.diary_generator.diary_generator import process_event, generate_diary
            # processed_events = [process_event(e) for e in events_data]
            # diary_text = generate_diary(processed_events)  # OpenAI 사용하지 않음
            diary_text = """ 오늘은 춘천의 김유정 레일바이크에서 하루를 시작했다. 경치 좋은 전망과 역사적인 장소에서 레일바이크를 타며 야외 활동을 즐겼다. 점순이 동상과 주변의 자연 경관이 조화롭게 어우러져 있어 마음이 편안해졌다.
 오후에는 산토리니 카페에서 디저트와 커피를 맛보았다. 황금빛 크로와상과 커피 한 잔의 여유가 기분을 좋게 했다. 카페는 사진 찍기 좋은 명소로, 맑은 하늘과 잘 어울리는 포토존이 인상적이었다.
 그리고 알파카월드로 향해 동물과 교감하는 시간을 가졌다. 알파카들과 먹이주기를 하며 자연 속에서 평화로운 시간을 보냈다. 하루 종일 자연과 함께하며 마음의 여유를 찾는 시간이었다."""
            emotion_id = events_data[0].get('emotion', 1)

            diary = Diary.objects.create(
                user=request.user,
                diary_date=validated_data.get('date'),
                final_text=diary_text,
                emotion_id_id=emotion_id,
                timeline_sent=validated_data.get('timeline_sent', []),
                markers=validated_data.get('markers', []),
                camera_target=validated_data.get('camera_target', {})
            )

            keywords = []
            for event in events_data:
                keywords.extend(event.get('keywords', []))

            # 중복 제거
            keywords = list(set(keywords))

            for keyword in keywords:
                keyword_obj, created = Keyword.objects.get_or_create(
                    content=keyword,
                    event_id=events[0].event_id if events else None
                )
                DiaryKeyword.objects.create(
                    diary=diary,
                    keyword=keyword_obj,
                    is_selected=True,
                    is_auto_generated=True
                )

            # for keyword in processed_events[0].get('keywords', []):
            #     keyword_obj, created = Keyword.objects.get_or_create(
            #         content=keyword,
            #         event_id=events[0].event_id if events else None
            #     )
            #     DiaryKeyword.objects.create(
            #         diary=diary,
            #         keyword=keyword_obj,
            #         is_selected=True,
            #         is_auto_generated=True
            #     )

            diary_serializer = DiarySerializer(diary)
            return Response(diary_serializer.data, status=status.HTTP_200_OK)

        except Exception as e:
            import traceback
            traceback.print_exc()
            return Response({
                "message": "Internal server error",
                "error": str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
