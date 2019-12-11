## 概要
k8s はマスターノードとワーカーノードに別れる。
   
それぞれ、以下の役割がある。

* マスターノードが認証と認可、リソースの管理、スケジューリング
* ワーカーノードがコンテナの実行部分

を担う。

マスターノード には、api-serverと呼ばれるコンポーネントが存在し、
ワーカーノードのkubeletからリクエストを受けた際にDeploymentやDaemonSetなどの
オブジェクトを作成、更新、削除する。

kubelet
- https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
   
Resourceの作成、更新、削除が発生した場合は、api-serverがこれを受けて、
オブジェクトの情報をetcdに格納する。  
基本的にetcdにアクセスするには、api-serverを介して行うことになる。

また、マスターノードにはcontroller-managerというコンポーネントが存在し、
k8s標準のリソースを管理している。

k8s標準のリソースとはつまり、DeploymentやDaemonsetであり、
これらのコントローラがバイナリとしてまとまっている形になっている。

ここでポイントなのが、controllerはcontrol loopというループが回っており、
これは、現在の状態と本来あるべき状態を比較し、現在の状態とあるべき状態に差がある場合は、
対象をあるべき状態に近づけるための監視ループになっている。

特にこのループを、Reconciliation Loop という。

control loop の大きな流れは、

* 対象リソースの状態を読み込み
* Desired state(あるべき姿)に合わせて、Actual state(現在の状態)を変更する
* 対象リソースの状態を更新する

となっている。


k8sには、ユーザが独自のリソースを定義し利用するための仕組みがあり、これをCRD
(custom resource definition)という。
k8s標準以外の、ユーザ独自のリソースをカスタムリソースという。

CRD以外にも以下のような方法で、k8sでカスタムリソースを扱う仕組みがある。
・admission webhook: apiリクエストを変更・検証するための仕組み
・api aggregation: APIを追加し、aggregation layerに追加する

admission webhookは最もシンプルだが、やりたいことが限られる。  
api aggregationは最も自由度が高いが、実装が複雑になっている。  
そのため、昨今ではCRDによる拡張が主流となっている。  

カスタムリソースを利用するためには、それを利用することを定義したCRDをk8sに登録する必要がある。 
  
具体的には、CRD用のyamlファイルとCR用のyamlファイルが必要になる。
CRD用のyamlファイルのapiVersionフィールドには、apiextensions.k8s.io/v1beta1
を定義する。

CR用のyamlファイルには、apiVersionフィールドに CRD用yamlファイルの api groupフィールドの値を設定し、
kindフィールドには、CRD用のkindフィールドの値を設定する。


## 用語の整理
カスタムコントローラ:
- k8s標準またはカスタムリソースの管理を行うコンポーネント

オペレータ：
- カスタムコントローラ + CRD のセット

## 実装方法

ここでは、オペレータを作るため、CRDの方式を用いることにする。

### シンプルコントローラー:

- https://github.com/kubernetes/sample-controller

#### client-go:
- api-serverにアクセスするためのクライアントモジュール
-  https://github.com/kubernetes/client-go/blob/master/kubernetes/clientset.go

#### apimachinery:
- k8s api オブジェクト
- https://github.com/kubernetes/apimachinery


## ほか

client-go及びapimachineryを利用してカスタムコントローラを実装するために、
以下のコンポーネントが重要になってくる。

※ただし、以下のコンポーネントはclient-goでの名称のため、同じような機能があれば、
他の言語でも十分にコントローラは実装可能。

* Informer: k8s上のオブジェクトを監視し in-memory-cacheにデータを格納する
* Lister: in-memory-cacheからデータを取得する
* Workqueue: 対象オブジェクトを登録するためのキュー
* Runtime.Object: 全てのオブジェクトで共通のインターフェース
* Scheme: k8s API を go の型定義に 変換するためのもの（定義しなおしたもの）

