import boto3
import os
from airflow import models, settings
from airflow.contrib.auth.backends.password_auth import PasswordUser

try:

    user = PasswordUser(models.User())

    username = os.environ['AIRFLOW_ADMIN_USER']
    password = os.environ.get('AIRFLOW_ADMIN_PASSWORD')
    # TODO retrieve password from secret manager, for example for stages that are not local

    user.password = str(password)
    user.superuser = True
    session = settings.Session()
    session.add(user)
    session.commit()
    session.close()
    print(f'Admin user with username {user} was added')
    exit()

except Exception as error:
    # if the user already exist this exception will be triggered
    print(error)
    raise error
