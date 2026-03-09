from django.db import migrations
from django.utils import timezone

def create_initial_diaries(apps, schema_editor):
    Diary = apps.get_model('diaries', 'Diary')

    initial_diaries = [
        # final_test에 일기 본문으로 대체 예정
        {'diary_date': '2025-04-23', 'final_text': '오늘은 서울 안에서 소소한 여행을 했다. 먼저 연남동 경의선 숲길을 걸으며 바람 부는 가을 공기를 만끽했다. 평소보다 한산한 거리에서 느껴지는 여유가 좋았다. 점심은 근처 브런치 카페에서 가지그라탕과 샐러드를 먹었다. 통유리창 밖으로 햇살이 쏟아져 분위기를 더해줬다. 마지막으로 망원한강공원에 들러 강변 산책을 하며 구름 사이로 지는 해를 바라봤다. 익숙한 서울도 다르게 보인 하루였다.', 'timeline_sent': [], 'markers': [], 'camera_target': [], 'created_at': timezone.datetime(2025, 4, 23, 18, 0, 0), 'updated_at': timezone.datetime(2025, 4, 23, 18, 0, 0), 'user_id': 1, 'emotion_id_id': 1},
        {'diary_date': '2025-04-25', 'final_text': '오늘은 경기도 광주 근교로 힐링 여행을 다녀왔다. 먼저 곤지암 화담숲에서 단풍을 보며 천천히 산책했다. 나무 사이로 흩어지는 햇살과 고운 잎들이 조화를 이루며 마치 수채화 같았다. 점심은 근처 농가 카페에서 유기농 브런치를 먹으며 창밖 들판을 바라봤다. 오후엔 왕실도자기박물관에서 조용히 도자기 전시를 감상하며 고요한 시간을 보냈다. 바쁜 일상 속에서 잠시 벗어나 마음의 여유를 되찾은 하루였다.', 'timeline_sent': [], 'markers': [], 'camera_target': [], 'created_at': timezone.datetime(2025, 4, 25, 18, 0, 0), 'updated_at': timezone.datetime(2025, 4, 25, 18, 0, 0), 'user_id': 1, 'emotion_id_id': 2},
        {'diary_date': '2025-04-28', 'final_text': '오늘은 구리, 하남, 그리고 남양주를 잇는 드라이브 여행을 했다. 구리 한강공원에서 자전거를 타며 한강변을 따라 바람을 맞았다. 점심은 하남 스타필드의 루프탑 레스토랑에서 즐겼는데, 멀리 남한산성과 산자락이 보였다. 오후엔 남양주 카페거리의 감성적인 찻집에서 오랜만에 손으로 편지를 썼다. 흐르는 음악과 창밖 풍경이 오롯이 내 감정을 받아주는 듯한 하루였다.', 'timeline_sent': [], 'markers': [], 'camera_target': [], 'created_at': timezone.datetime(2025, 4, 28, 18, 0, 0), 'updated_at': timezone.datetime(2025, 4, 28, 18, 0, 0), 'user_id': 1, 'emotion_id_id': 3},
        {'diary_date': '2025-05-01', 'final_text': '오늘은 인천 송도에서 도심 속 여유를 느꼈다. 오전엔 센트럴파크를 걸으며 수로 옆 갈대숲 사이로 햇살을 즐겼다. 강 위를 떠다니는 수상택시를 보며 이국적인 분위기를 느꼈다. 점심은 현대적인 디자인의 카페에서 아보카도 샐러드와 스무디를 맛봤다. 오후엔 트라이볼 전시장을 방문해 현대미술 작품을 감상했다. 도시와 예술, 자연이 한데 어우러진 경험이었다.', 'timeline_sent': [], 'markers': [], 'camera_target': [], 'created_at': timezone.datetime(2025, 5, 1, 18, 0, 0), 'updated_at': timezone.datetime(2025, 5, 1, 18, 0, 0), 'user_id': 1, 'emotion_id_id': 1},
        {'diary_date': '2025-05-05', 'final_text': '오늘은 남양주를 다녀왔다. 아침엔 물의정원 산책로를 따라 걸으며 한적한 강변 풍경을 감상했다. 갈대와 억새가 부드럽게 흔들리는 모습이 인상적이었다. 이어서 두물머리로 이동해 느긋하게 강변 벤치에 앉아 따뜻한 커피를 마셨다. 주변 풍경과 어우러지는 고즈넉한 정취가 마음을 차분하게 만들었다. 마지막으로 천마산역 근처의 수목원 카페에 들러, 나무 사이로 햇살이 스며드는 공간에서 책을 읽으며 하루를 마무리했다. 자연과 함께한 하루가 위로처럼 느껴졌다.', 'timeline_sent': [], 'markers': [], 'camera_target': [], 'created_at': timezone.datetime(2025, 5, 5, 18, 0, 0), 'updated_at': timezone.datetime(2025, 5, 5, 18, 0, 0), 'user_id': 1, 'emotion_id_id': 1},
        {'diary_date': '2025-05-10', 'final_text': '오늘은 양평을 여행했다. 먼저 세미원에서 연꽃과 수련을 보며 물가를 따라 산책했다. 연못 위에 떠 있는 연잎과 바람에 스치는 꽃향기가 기분을 맑게 해줬다. 그 다음으로는 두물머리에서 자전거를 타며 탁 트인 한강 풍경을 감상했다. 자전거 도로 옆 노란 은행잎이 가을을 실감나게 했다. 마지막은 카페 노을에서 바라본 석양이었다. 강 너머로 퍼지는 붉은 노을이 하루의 끝을 감동적으로 장식해줬다.', 'timeline_sent': [], 'markers': [], 'camera_target': [], 'created_at': timezone.datetime(2025, 5, 10, 18, 0, 0), 'updated_at': timezone.datetime(2025, 5, 10, 18, 0, 0), 'user_id': 1, 'emotion_id_id': 6},
    ]

    for diary_data in initial_diaries:
        Diary.objects.create(**diary_data)

class Migration(migrations.Migration):

    dependencies = [
        ('diaries', '0003_diary_emotion_id'),
        ('users', '0002_initial_users'),
    ]

    operations = [
        migrations.RunPython(create_initial_diaries),
    ]
