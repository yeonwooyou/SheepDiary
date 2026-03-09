from rest_framework import serializers
from .models import User, Agreement, UserProfilePicture, UserAlarmSetting
from diaries.models import Diary
from django.db import models
from drf_spectacular.utils import extend_schema_field


class DailyStatusSerializer(serializers.Serializer):
    is_authenticated = serializers.BooleanField()
    today_date = serializers.DateField()
    emotion = serializers.CharField(allow_null=True)
    diary_exists = serializers.BooleanField()


class UserProfileResponseSerializer(serializers.Serializer):
    user_id = serializers.IntegerField()
    user_name = serializers.CharField()
    email = serializers.EmailField()
    # profile_image_url = serializers.URLField()
    joined_date = serializers.DateTimeField(format="%Y-%m-%d", read_only=True)
    diary_count = serializers.IntegerField(default=0)
    last_diary_date = serializers.DateField(allow_null=True, default=None)