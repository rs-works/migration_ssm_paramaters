# migration_ssm_paramaters
SSMパラメータストアの値を移行するスクリプト
実行計画と承認ステップのあと処理する

ex). アカウントAの/example/fooの値をアカウントBの/example/barに移行する

```bash
$ sh migration_ssm_paramaters.sh \
   --from_profile account_A \
   --to_profile   account_B \
   --from_key     /example/foo \
   --to_key       /example/bar

------------------------------------
Migration SSM Paramater Stores Value
------------------------------------
From
    profile = account_A
    key     = /example/foo
    value   = 123
To
    profile = account_B
    key     = /example/bar
  ~ value   = ABC -> 123

ok? (y/N): y

Complate Migration
```
