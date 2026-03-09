import os
import textwrap
from typing import List

# --- 데모 데이터 ---

# 데모용 이미지 캡션 데이터
# 실제 API 호출을 대체하기 위한 목업 데이터입니다.
DEMO_IMAGE_CAPTIONS = {
    "demo01.jpg": "이 사진은 '춘천 김유정 레일바이크'에 위치한 동백꽃 소설 속 인물 점순이의 동상을 담고 있습니다. "
                "동상은 야외에 설치되어 있으며, 캐릭터의 표정을 사실적으로 표현해 인물의 생동감을 강조하고 있습니다. "
                "주변에는 나무와 풀들이 자연스럽게 어우러져 있어 시골 마을의 고요하고 따뜻한 분위기를 자아냅니다.",
    "demo02.jpg": "이 사진은 '춘천 김유정 레일바이크' 인근의 화원을 담고 있으며, 핑크뮬리가 넓게 퍼져 장관을 이루고 있습니다. "
                "뒤편에는 낮은 산들이 부드러운 실루엣으로 펼쳐져 있고, 맑고 파란 하늘이 전체 배경을 감싸며 풍경의 탁 트인 느낌을 더욱 강조해 줍니다.",
    "demo03.jpg": "이 사진은 춘천의 한 카페의 포토존을 보여줍니다. 설치된 건축 구조물은 높은 곳에 위치해 있으며, "
                "하얀색으로 깔끔하게 마무리되어 있습니다. 이 구조물은 전통적인 아치형 디자인을 현대적으로 해석한 것 같으며, "
                "정상에는 작은 장식적인 요소가 보입니다. 배경으로는 맑은 하늘이 펼쳐져 있으며, "
                "햇빛이 구조물을 밝게 비추고 있어 사진 촬영 장소로서 매력적인 환경을 제공합니다.",
    "demo04.jpg": "이 사진은 춘천의 한 카페에서 찍은 것으로 보입니다. 사진에는 잘 구워진 황금빛 크로와상 하나가 흰색 접시에 담겨 있으며, "
                "옆에는 나무 포크와 나이프가 놓여 있습니다. 둥근 나무 테이블 위에는 두 개의 파란 무늬가 있는 종이컵에 담긴 커피가 보이는데, "
                "한 컵은 카푸치노로 보이며 위에 초콜릿 소스로 격자 무늬 장식이 되어 있고, 다른 한 컵은 라떼로 보입니다. "
                "전체적인 배치와 조화로운 컬러가 포토존으로서의 매력을 더해주는 카페 분위기를 잘 나타내고 있습니다.",
    "demo05.jpg": "알파카들이 자연스러운 환경에서 평화롭게 지내는 모습이 담긴 이 사진은 몇몇 알파카들이 나무 울타리 안에서 "
                "구경오는 방문객들을 바라보고 있는 장면을 보여줍니다. 흙길과 녹색의 나무들이 배경에 있어 자연의 느낌을 더해줍니다. "
                "알파카 중 하나는 특히 카메라를 향해 고개를 들고 있는데, 그 모습이 귀엽고 친근감을 줍니다.",
    "demo06.jpg": "이 사진은 대형 알파카 캐릭터 조형물이 마음을 표현하는 하트 모양의 물체를 들고 있는 모습을 보여줍니다. "
                "이 밝은 표정의 알파카는 자연 속에서 평화로움과 친근함을 느끼게 하며, "
                "배경에는 푸른 하늘과 조그만 건물이 보여 자연스러운 환경 속에서 조화롭게 자리잡고 있습니다."
}

# 데모용으로 생성될 최종 일기
# 실제 API 호출 시 반환될 결과 예시입니다.
MOCK_DIARY_CONTENT = """
오늘은 춘천과 홍천을 오가며 다채로운 하루를 보냈다. 김유정 레일바이크에서 점순이 동상도 보고, 핑크뮬리가 가득한 화원에서 가을의 정취를 흠뻑 느꼈다. 
산토리니 카페의 이국적인 포토존에서 사진을 남기고, 맛있는 크로와상과 커피로 여유를 즐겼다. 
오후에는 홍천 알파카월드로 넘어가 귀여운 알파카들과 교감하며 평화로운 시간을 보냈다. 
자연 속에서 동물들과 함께하니 마음이 절로 치유되는 기분이었다. 잊지 못할 하루다.
"""

# --- 목업(Mock-up) 함수 ---

def get_captions_from_images(image_paths: List[str]) -> List[str]:
    """
    이미지 경로 리스트를 받아 데모 캡션을 반환합니다.
    실제로는 이미지 분석 API를 호출해야 하지만, 여기서는 데모용으로 구현되었습니다.
    """
    # 이미지 경로와 관계없이 모든 데모 캡션을 반환합니다.
    return list(DEMO_IMAGE_CAPTIONS.values())

def build_diary_prompt(events: List[dict]) -> str:
    """
    이벤트 정보를 바탕으로 LLM에 전달할 프롬프트를 생성합니다.
    """
    # 각 이벤트에 대해 캡션을 포함한 요약 정보를 생성합니다.
    event_summaries = []
    for event in events:
        # 목업 함수를 통해 이미지 캡션을 가져옵니다.
        captions = get_captions_from_images(event.get("images", []))
        combined_caption = " ".join(captions)

        event_summaries.append({
            "event_id": event.get("id", 0),
            "place": event.get("place", "알 수 없는 장소"),
            "emotion": event.get("emotion", "알 수 없는 감정"),
            "keywords": event.get("keywords", ["키워드 없음"]),
            "combined_caption": combined_caption,
        })

    # 프롬프트에 포함될 이벤트 정보 문자열을 생성합니다.
    events_str = "\n".join(
        [
            f"""일상 사건 {event['event_id']}:
            - 장소: {event['place']}
            - 감정: {event['emotion']}
            - 키워드: {', '.join(event['keywords'])}
            - 관련 사진 묘사: {event['combined_caption']} """
            for event in event_summaries
        ]
    )

    # 최종 프롬프트 템플릿
    prompt_template = textwrap.dedent(
        """
        너는 사실적이고 담백한 어조로 하루를 정리하는 일기 작가야.
        감정에 치우치지 않고, 사진에 담긴 상황과 분위기, 그날의 감정을 자연스럽게 설명해줘.

        [작성 조건]
        - 아래 [일상 사건 정보]를 참고해서 너무 감성적이지 않게, 담백하고 솔직한 반말 일기체로 작성해줘.
        - 모든 문장은 한국어 '~다'로 끝나는 형식을 지켜줘.
        - 단순 나열이 아닌 하나의 흐름으로, 의미 있는 하루처럼 정리해줘.
        - 글 길이는 300~500자 정도로 맞춰줘.

        [일상 사건 정보]
        {events}
        """
    )

    return prompt_template.format(events=events_str)

def generate_diary_mock(prompt: str) -> str:
    """
    생성된 프롬프트를 받아 목업 일기를 반환합니다.
    실제로는 이 부분에서 LangChain과 LLM API가 호출됩니다.
    """
    print("---" 생성된 프롬프트 ---")
    print(prompt)
    print("--------------------")
    print("\n--- API 호출 (Mocked) ---")
    print("LLM API에 프롬프트를 전달하여 일기 생성을 요청합니다...")
    print("--------------------
")
    
    # 실제 API 호출 대신 하드코딩된 목업 데이터를 반환합니다.
    return MOCK_DIARY_CONTENT

if __name__ == "__main__":

    # 데모용 이벤트 데이터 정의
    demo_events = [
        {
            "id": 1,
            "images": ["demo01.jpg", "demo02.jpg"],
            "place": "춘천 김유정 레일바이크",
            "emotion": "행복",
            "keywords": ["춘천", "레일바이크", "김유정", "핑크뮬리"],
        },
        {
            "id": 2,
            "images": ["demo03.jpg", "demo04.jpg"],
            "place": "춘천 산토리니 카페",
            "emotion": "즐거움",
            "keywords": ["춘천", "카페", "포토존", "크로와상"],
        },
        {
            "id": 3,
            "images": ["demo05.jpg", "demo06.jpg"],
            "place": "홍천 알파카월드",
            "emotion": "평화로움",
            "keywords": ["알파카", "자연", "평화"],
        },
    ]

    # 1. 이벤트 정보로 프롬프트 생성
    final_prompt = build_diary_prompt(demo_events)

    # 2. 생성된 프롬프트로 목업 일기 생성
    diary_content = generate_diary_mock(final_prompt)

    # 3. 최종 결과 출력
    print("--- 최종 생성된 일기 ---")
    print(diary_content)
