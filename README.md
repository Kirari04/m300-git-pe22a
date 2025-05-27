# hetzner-k3s - Nextcloud

## Ressourcen

- Hetzner K3s [https://github.com/vitobotta/hetzner-k3s](https://github.com/vitobotta/hetzner-k3s)
- Nextcloud Helm Chart [https://github.com/nextcloud/helm/blob/main/charts/nextcloud/README.md](https://github.com/nextcloud/helm/blob/main/charts/nextcloud/README.md#introduction)
- [Mysql + Replica](https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/)

## Testing

Zuerst wird alles mit https://microk8s.io/ getestet.

### Microk8s installieren

```bash
sudo snap install microk8s --classic

sudo usermod -a -G microk8s user
sudo chown -R user ~/.kube

microk8s status --wait-ready

microk8s enable dashboard

microk8s enable dns

microk8s enable registry
```

