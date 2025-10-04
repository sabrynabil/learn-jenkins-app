FROM nginx:1.27-alpine
COPY build/ /usr/share/nginx/html
# FROM mcr.microsoft.com/playwright:v1.39.0-jammy
# RUN npm install -g netlify-cli@20.1.1 serve       
# RUN apt update && apt install -y jq
# WORKDIR /app
# COPY . . /app
# RUN npm install                                   