AIRFLOW_VERSION="1.10.3"

airflow-up:
	@docker-compose up --build

airflow-down:
	@docker-compose down

clean:
	@rm -rf postgres_data

install-airflow:
	@pip install git+https://github.com/apache/incubator-airflow.git@${AIRFLOW_VERSION}#egg=apache-airflow[crypto,kubernetes,password,postgres,s3,slack]

install-deps:
	@pip install -r requirements.txt

activate-env:
	. ./venv/bin/activate