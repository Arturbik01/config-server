FROM eclipse-temurin:25 as build
WORKDIR application
LABEL authors="Arturbik"
# Переменная пробрасывается из pom.xml
ARG JAR_FILE=target/*.jar
#Забираем jar-приложение в образ
COPY ${JAR_FILE} application.jar
#Распаковка jar на составляющие
RUN java -Djarmode=layertools -jar application.jar extract

#Step 2
FROM eclipse-temurin:25
WORKDIR application

#Копируем из первого шага во второй шаг только нужные слои для запуска этого микросервиса
COPY --from=build application/dependencies/ ./
COPY --from=build application/spring-boot-loader/ ./
COPY --from=build application/snapshot-dependencies/ ./
COPY --from=build application/application/ ./

#Расхождение с книгой: Класс JarLauncher был перенесен с версии 3.x
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]