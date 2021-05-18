# migration_ssm_paramaters
SSMパラメータストアの値を移行するスクリプト

ex). アカウントAの/example/fooの値をアカウントBの/example/barに移行する

```bash
sh migration_ssm_paramaters.sh \
   --from_profile account_A \
   --to_profile   account_B \
   --from_key     /example/foo \
   --to_key       /example/bar
```
