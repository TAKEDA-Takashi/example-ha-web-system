# example-ha-web-system

## ローカルでDockerコンテナを起動する

```bash
$ cd apps/
$ docker-compose up
```

`8080`ポートで起動するので`curl`などで動作確認できます。

```bash
$ curl localhost:8080/api/hello
```

## AWS上に環境を構築する

### platformについて

M1 Macで検証した都合上、Fargateのプラットフォームとしてarm64を指定しています。amd64環境でビルドしてECSがうまく起動しない場合、次のいずれかを試してみてください。

- Dockerイメージをビルドする際に、明示的にarm64を指定する
- `apps/task-definition.json`を修正して`cpuArchitecture`にamd64を指定する

### スクリプト実行

`./scripts/0_env.sh`で、スクリプトで使用する変数を定義しています。実行する環境に合わせて変更してください。

```bash
$ . ./scripts/0_env.sh
$ . ./scripts/1_vpc.sh
$ . ./scripts/2_ecr.sh
$ . ./scripts/3_task-definition.sh
$ . ./scripts/4_alb.sh
$ . ./scripts/5_ecs.sh
$ . ./scripts/6_route53.sh
$ . ./scripts/7_acm.sh
```

## 環境の削除

特に削除スクリプトなどは用意していません。手動で削除するか自前でスクリプトを組んでください。
