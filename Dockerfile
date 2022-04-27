### STAGE 1: Build ###
FROM registry.redhat.io/ubi8/nodejs-14:1-63.1647451870 AS build

#### make the 'app' folder the current working directory
WORKDIR /usr/src/app

#### copy both 'package.json' and 'package-lock.json' (if available)
COPY package*.json ./

#### install angular cli
RUN npm install -g @angular/cli

#### install project dependencies
RUN npm install

#### copy things
COPY . .

#### generate build --prod
RUN npm run build:ssr

### STAGE 2: Run ###
FROM registry.redhat.io/rhel8/nginx-116:1-112

#### copy nginx conf
COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/default.conf /etc/nginx/conf.d/default.conf

#### copy artifact build from the 'build environment'
COPY --from=build /usr/src/app/dist/angular-tour-of-heroes/browser /usr/share/nginx/html
USER root
RUN id && chown nginx:nginx /usr/share/nginx/html/*
USER nginx

#### don't know what this is, but seems cool and techy
CMD ["nginx", "-g", "daemon off;"]
