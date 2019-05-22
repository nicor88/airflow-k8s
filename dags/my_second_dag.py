from datetime import datetime
import logging

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.contrib.operators.kubernetes_pod_operator import KubernetesPodOperator

import pandas
import toolz

logger = logging.getLogger(__name__)

default_args = {
    'owner': 'nicor88',
    'start_date': datetime(2019, 2, 20),
    'depends_on_past': False,
    'provide_context': True
}

dag = DAG('my_second_dag',
          description='My second Airflow DAG',
          schedule_interval='*/15 * * * *',
          catchup=False,
          default_args=default_args)


def task_1(**kwargs):
    output = {'output': 'hello world 1', 'execution_time': str(datetime.now())}
    logger.info(output)
    logger.info(f'Pandas version: {pandas.__version__}')
    logger.info(f'Toolz version: {toolz.__version__}')
    return output


def task_2(**kwargs):
    ti = kwargs['ti']
    output_task_1 = ti.xcom_pull(key='return_value', task_ids='task_1')
    logger.info(output_task_1)
    return {'output': 'hello world 2', 'execution_time': str(datetime.now())}


def task_3(**kwargs):
    logger.info('Log from task 3')
    return {'output': 'hello world 3', 'execution_time': str(datetime.now())}


def task_4(**kwargs):
    logger.info('Log from task 4')
    return {'output': 'hello world 4', 'execution_time': str(datetime.now())}

t1 = PythonOperator(
    task_id='task_1',
    dag=dag,
    python_callable=task_1
)

t2 = PythonOperator(
    task_id='task_2',
    dag=dag,
    python_callable=task_2
)

t3 = PythonOperator(
    task_id='task_3',
    dag=dag,
    python_callable=task_3
)

t4 = PythonOperator(
    task_id='task_4',
    dag=dag,
    python_callable=task_4
)

t5 = KubernetesPodOperator(namespace='airflow',
                           image="python:3.6",
                           cmds=["python", "-c"],
                           arguments=["print('hello world')"],
                           labels={"foo": "bar"},
                           name="task_5t",
                           task_id="task_5",
                           get_logs=True,
                           dag=dag
                           )

t1 >> [t2, t3] >> t4 >> t5
