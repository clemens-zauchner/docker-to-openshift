FROM python:3.7-alpine 
EXPOSE 8000
RUN mkdir -p /app
RUN apk add --no-cache --update sqlite sqlite-dev
WORKDIR /app 
COPY requirements.txt /app
RUN pip3 install -r requirements.txt --no-cache-dir
COPY . /app 
ENTRYPOINT ["python3"] 
CMD ["manage.py", "runserver", "0.0.0.0:8000"]
