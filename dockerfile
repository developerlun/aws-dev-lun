FROM python:3.11

WORKDIR /app

COPY . /app

RUN pip3 install flask

EXPOSE 5001

CMD ["flask", "run", "--host=0.0.0.0", "--port=5001"]

