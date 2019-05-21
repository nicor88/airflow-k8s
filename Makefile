AIRFLOW_VERSION="1.10.3"

airflow-celery-up:
	@docker-compose -f docker-compose-celery.yml up --build

airflow-celery-down:
	@docker-compose -f docker-compose-celery.yml down

airflow-local-up:
	@docker-compose -f docker-compose-local.yml up --build

airflow-local-down:
	@docker-compose -f docker-compose-local.yml down

clean:
	@rm -rf postgres_data

install-airflow:
	@pip install git+https://github.com/apache/incubator-airflow.git@${AIRFLOW_VERSION}#egg=apache-airflow[crypto,kubernetes,password,postgres,s3,slack]

install-deps:
	@pip install -r requirements.txt

activate-env:
	. ./venv/bin/activate