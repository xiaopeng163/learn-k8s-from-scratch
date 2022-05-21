Minikube
===========

Minikube是一个可以快速搭建Kubernetes的工具

Minukube 文档 https://minikube.sigs.k8s.io/docs/start/

下载： https://github.com/kubernetes/minikube/releases

Pre-Requirements
--------------------

Minukube搭建k8s环境是通过创建虚拟机或者Docker容器的方式实现的：

- 虚拟机，就是创建启动几个虚拟机，然后安装k8s
- 通过docker创建几个容器，然后把k8s安装和启动在这些容器里

这些不同的方式是通过不同的Driver实现的，具体Minukube所支持的Driver可以通过这个link查看

https://minikube.sigs.k8s.io/docs/drivers/


对于Windows和Mac的机器，建议使用虚拟化的方式进行（也就是说要保证你的机器可以成功的创建和启动虚拟机），要满足以下条件：

- BIOS开启虚拟化
- 要有安装一个虚拟化的 ``hypervisor``:
    - VirtualBox
    - VMware workstation/ VMware Fusion
    - 或者其它



Install Steps for Windows
----------------------------

打开powershell，运行

.. code-block:: powershell

    New-Item -Path 'c:\' -Name 'minikube' -ItemType Directory -Force
    Invoke-WebRequest -OutFile 'c:\minikube\minikube.exe' -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe' -UseBasicParsing

为了能直接在命令行中使用minikube命令，而不是每次都输入 c:\minikube\minikube.exe，有两种方式：

添加环境变量
~~~~~~~~~~~~~

添加环境变量，以管理员身份打开powershell运行

.. code-block:: powershell

    $oldPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
    if ($oldPath.Split(';') -inotcontains 'C:\minikube'){ `
        [Environment]::SetEnvironmentVariable('Path', $('{0};C:\minikube' -f $oldPath), [EnvironmentVariableTarget]::Machine) `
    }

添加Alias
~~~~~~~~~~~

如果不想修改环境变量，也可以通过设置Alias实现，非管理员打开powershell

运行

.. code-block:: powershell

    notepad.exe $PROFILE

这个会用notepad打开一个powershell的profile文件（如果是第一次运行，那么会提示你要新建一个文件，点击确定）


把以下内容贴到文件中，保存关闭文件，然后重启打开powershell

.. code-block:: powershell

    Set-Alias -Name minikube -Value C:\minikube\minikube.exe

就可以直接在命令行中使用minikube命令了

.. code-block:: powershell

    PS C:\Users\Peng Xiao> minikube
    minikube provisions and manages local Kubernetes clusters optimized for development workflows.

    Basic Commands:
    start          Starts a local Kubernetes cluster
    status         Gets the status of a local Kubernetes cluster
    stop           Stops a running local Kubernetes cluster
    delete         Deletes a local Kubernetes cluster
    dashboard      Access the Kubernetes dashboard running within the minikube cluster
    pause          pause Kubernetes
    unpause        unpause Kubernetes

    Images Commands:
    docker-env     Configure environment to use minikube's Docker daemon
    podman-env     Configure environment to use minikube's Podman service
    cache          Add, delete, or push a local image into minikube
    image          Manage images

    Configuration and Management Commands:
    addons         Enable or disable a minikube addon
    config         Modify persistent configuration values
    profile        Get or list the current profiles (clusters)
    update-context Update kubeconfig in case of an IP or port change

    Networking and Connectivity Commands:
    service        Returns a URL to connect to a service
    tunnel         Connect to LoadBalancer services

    Advanced Commands:
    mount          Mounts the specified directory into minikube
    ssh            Log into the minikube environment (for debugging)
    kubectl        Run a kubectl binary matching the cluster version
    node           Add, remove, or list additional nodes
    cp             Copy the specified file into minikube

    Troubleshooting Commands:
    ssh-key        Retrieve the ssh identity key path of the specified node
    ssh-host       Retrieve the ssh host key of the specified node
    ip             Retrieves the IP address of the specified node
    logs           Returns logs to debug a local Kubernetes cluster
    update-check   Print current and latest version number
    version        Print the version of minikube
    options        Show a list of global command-line options (applies to all commands).

    Other Commands:
    completion     Generate command completion for a shell

    Use "minikube <command> --help" for more information about a given command.
    PS C:\Users\Peng Xiao>

minikube start
~~~~~~~~~~~~~~~~


以VirtualBox驱动和 v1.24.0版本的Kubernetes为例

.. code-block:: powershell

    minikube start --driver=virtualbox --kubernetes-version=v1.24.0


kubectl
~~~~~~~~~~

可以通过minikube来运行kubectl

.. code-block:: powershell

    minikube kubectl -- <kubectl commands>

为了方便，也可以把下面的alias加到powershell的 PROFILE里


.. code-block:: powershell

    function kubectl { minikube kubectl -- $args }
    doskey kubectl=minikube kubectl $*


Install Steps for MacOS
----------------------------


x86芯片
~~~~~~~~~~~~~

.. code-block:: bash

    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
    sudo install minikube-darwin-amd64 /usr/local/bin/minikube

M1 ARM芯片
~~~~~~~~~~~~~~

.. code-block:: bash

    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64
    sudo install minikube-darwin-arm64 /usr/local/bin/minikube


启动
~~~~~~

如果是x86芯片，可以使用VirtualBox


.. code-block:: bash

    minikube start --driver=virtualbox --kubernetes-version=v1.24.0


如果是ARM芯片，可以使用docker


.. code-block:: bash

    minikube start --driver=docker --alsologtostderr --kubernetes-version=v1.24.0


设置Alias

.. code-block:: bash

    alias kubectl="minikube kubectl --"
