# use a smaller base image to reduce image size and pull time
FROM nginx:alpine

# set working directory inside the container
WORKDIR /usr/share/nginx/html

# copy site files into the container (keep this as a single layer)
# .dockerignore will prevent unnecessary files from being sent in the build context
COPY . /usr/share/nginx/html

# expose http port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]