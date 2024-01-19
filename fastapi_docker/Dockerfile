FROM python:3.10

# code 폴더 workplace
WORKDIR /code

# 패키지 복사
COPY ./requirements.txt /code/requirements.txt
 
# 패키지 설치
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt
 
# 아래 두줄은 만약 도커로 배포를 한다면 주석해제하고 사용하면 된다. 
#COPY ./app /code/app
 
#CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]