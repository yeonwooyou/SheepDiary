from django.db import migrations
from django.contrib.auth.hashers import make_password

def create_initial_user(apps, schema_editor):
    User = apps.get_model('users', 'User')

    # 비밀번호를 해시 처리
    password = make_password('test')

    User.objects.create(
        email='6kimjinwook@gmail.com',
        user_name='GlazedBream',
        password=password
    )

    User.objects.create(
        email='lieben94@naver.com',
        user_name='lieben94',
        password=password
    )

class Migration(migrations.Migration):

    dependencies = [
        ('users', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(create_initial_user),
    ]
