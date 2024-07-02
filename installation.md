# Installation Instructions

## ViNL GitHub Repo
Git clone the [ViNL GitHub repository](https://github.com/SimarKareer/ViNL):
```
git clone --recurse-submodules git@github.com:SimarKareer/ViNL.git
```

## Miniconda
Install `miniconda` from this link: https://docs.anaconda.com/miniconda/

## Setup.sh
Run the `setup.sh` executable. If you find any problem you always can run line by line the content of the file.

Personally, I recommend to create an alias for the virtual environment, something like the following (modify it as convenient).
```
alias vinl="conda activate vinl && cd ~/Documents/TFM/ViNL && export LD_LIBRARY_PATH=~/miniconda3/envs/vinl/lib/"
```

## Running simulations

The full training `locomotion policy` can be done easily with the help of `my_train.sh` file. Before running it remember to make it executable:
```
chmod +x my_train.sh
```

Also, some minor changes will necesary:

1) To avoid any problems regardin the *argument parser* you will need to manually edit the `helpers.py` file. It is located in the `legged_gym/utils` folder. In the line `213`, within the `--checkpoint` argument, you need to change the `type` from `int` to `str`.
2) ``` export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json ```
3) At the time to record frames when evaluating a trained model, it will be necessary to change lines from `167` to `172` in the `legged_gym/scripts/play.py` file. Basically you need to include the correct path depending on your ViNL folder location. Also change to `True` the `RECORD_FRAMES` global variable (at the end of the same file). Finally, for a proper recording of the robot's movements uncomment the code line `46` that says: `env.follow_cam` and comment the one behind (`env.floating_cam,`).
4) Also install `FFmpeg` within your virtual environment with
    ```
    conda install -c conda-forge ffmpeg
    ```
5) Please do not forget to edit all the `aliengo_#_config.py` files in order to clean the `runner`. All of them could be something like this:
    ```
    class runner(LeggedRobotCfgPPO.runner):
        alg = "ppo"
        run_name = "rough"
        experiment_name = "rough_aliengo"

        max_iterations = 3500
    ```
    for the others change the names properly {rough, obstacles, lbc}.
6) It is also necessary to create the next structure: `exported/frames/00000.png` in your `run_name` folder within the `logs` folder. And the same should be done for the rest of training stages. Here an example for two stages {rough and obstacles}:
    ```
    ViNL
    |- logs
       |- rough_aliengo
       |   |- exported
       |      |- frames
       |         |- 00000.png
       |- obs_aliengo
          |- exported
             |- frames
                |- 00000.png 
    ```

<!-- 
7) Could be convenient to include a new parser option in the `legged_gym/utils/helpers.py` file (in line `217`):
    ```
    {
        "name": "--resume_path",
        "type": str,
        "help": "Path from which to load the weights for the training, when resume=True.",
    },
    ```
    and will be also necessary to include in the `helpers.py` file the next (in line `156`):
    ```
    if args.resume_path is not None:
        cfg_train.runner.resume_path = args.resume_path
    ``` 
-->

7) In the `legged_gym/utils/logger.py` file there is a function called `plot()` which could be really helpful but... utilices a lot of memory and makes the training execution do not work properly. We recomend not using it when launching `my_train.sh`. But could be helpful when launching indiviual training stages.

## Troubleshooting
1) If you found a message like this:
   ```
   [libprotobuf FATAL google/protobuf/stubs/common.cc:83] This program was compiled against version 3.6.1 of the Protocol Buffer runtime library, which is not compatible with the installed version (3.20.1). Contact the program author for an update. If you compiled the program yourself, make sure that your headers are from the same version of Protocol Buffers as your link-time library. (Version verification failed in "bazel-out/k8-opt/genfiles/tensorflow/core/framework/tensor_shape.pb.cc".) terminate called after throwing an instance of 'google::protobuf::FatalException' what(): This program was compiled against version 3.6.1 of the Protocol Buffer runtime library, which is not compatible with the installed version (3.20.1). Contact the program author for an update. If you compiled the program yourself, make sure that your headers are from the same version of Protocol Buffers as your link-time library. (Version verification failed in "bazel-out/k8-opt/genfiles/tensorflow/core/framework/tensor_shape.pb.cc".) Aborted (core dumped)
   ``` 
   These pip installs have finally solved the problem for me:
    ```
    pip install tensorflow==1.15.0
    pip install tensorboard==1.15.0

    pip install protobuf==3.8.0

    pip install torch
    pip install webdataset msgpack objectio
    pip install moviepy decorator proglog
    pip install tensorflow-estimator mock
    pip install keras-applications h5py
    ```
    If you check for remaining isues with `pip check` you may see someone related with `habitat-lab`; will be solved later...