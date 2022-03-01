# scaling-docker-solution
A solution to scale (up &amp; down) docker runners on a macos/windows/linux system.

*Prerequsites:*

1. You will need an active runner on a machine that has docker installed, for instance, I used my MacBook, but you can use an Ubuntu EC2 Instance.
2. Populate your CCI project env vars with the following, and populate with the correct infomation:
      - RESOURCE_CLASS = Your docker runners resource-class
      - DOCKER_RESOURCE_TOKEN = Your docker runners resource-class token
      - CIRCLE_TOKEN = Your CCI API token
      - DOCKER_IMAGE_ID = The image ID of whatever docker image you want your resource-class to use

Once you have done the above, you should be able to run the pipeline and watch as your containers spin up based on how many waiting tasks you have for a specified resource-class. 

Once no more tasks are running for that resource-class, the containers will be removed.

Scaling script polling for waiting jobs:
![Screenshot 2022-01-26 at 15 33 31](https://user-images.githubusercontent.com/25537601/151194202-c9364714-c0f2-4bc2-a4e1-f1d316765d69.png)

6 Containers created based on amount of waiting jobs:
![Screenshot 2022-01-26 at 15 33 54](https://user-images.githubusercontent.com/25537601/151194200-b40c1593-9c03-4215-93a6-958cd266c5d8.png)

Jobs are complete, so containers are removed:
![Screenshot 2022-01-26 at 15 34 04](https://user-images.githubusercontent.com/25537601/151194190-521c7a08-fda4-48e9-b484-9211b5a10094.png)

