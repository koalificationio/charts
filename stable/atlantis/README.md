1. Make sure that secret {{ template "atlantis.fullname" . }}-git-ssh exists in the same namespace with Atlantis if you're not using gitSSh create from values. It can be created with this command:

```bash
kubectl create secret generic atlantis-gitlab-ssh --from-file=id_rsa_ci_bot=id_rsa_ci_bot --from-file=config=ssh_config -n infra
```

2. SSH config file should look like this:

```text
Host gitlab-service.example.com
    IdentityFile ~/.ssh/id_rsa_ci_bot
    StrictHostKeyChecking No
```

3. Git config can look like this:
```
[url "https://oauth2:secret@gitlab.com"]
    insteadOf = https://gitlab.com
```
