# Política IAM para Terraform

Esta política incluye todos los permisos necesarios para que Terraform pueda crear la infraestructura completa del proyecto (VPC, EKS, ECR, OIDC, etc.).

## Cómo aplicar la política

### Opción 1: Desde la consola de AWS (Recomendado)

1. Ve a **AWS Console** → **IAM** → **Policies** → **Create policy**
2. Click en la pestaña **JSON**
3. Copia y pega el contenido de [`terraform-iam-policy.json`](file:///home/benja/Escritorio/DevOps-PrimerosPasos/DevOps-Primeros-Pasos/docs/terraform-iam-policy.json)
4. Click **Next**
5. Nombre de la política: `TerraformDevOpsFullAccess`
6. Descripción: `Política completa para Terraform - Proyecto DevOps`
7. Click **Create policy**
8. Ve a **IAM** → **Users** → **Terraform-admin** → **Add permissions**
9. Selecciona **Attach policies directly**
10. Busca y selecciona `TerraformDevOpsFullAccess`
11. Click **Add permissions**

### Opción 2: Desde la CLI de AWS

```bash
# Crear la política
aws iam create-policy \
  --policy-name TerraformDevOpsFullAccess \
  --policy-document file://docs/terraform-iam-policy.json

# Obtener el ARN de la política (reemplaza ACCOUNT_ID con tu número de cuenta)
POLICY_ARN="arn:aws:iam::573636633956:policy/TerraformDevOpsFullAccess"

# Adjuntar la política al usuario
aws iam attach-user-policy \
  --user-name Terraform-admin \
  --policy-arn $POLICY_ARN
```

## Permisos incluidos

La política incluye permisos para:

- **EC2**: VPC, Subnets, NAT Gateway, Security Groups, etc.
- **EKS**: Crear y gestionar clusters de Kubernetes
- **IAM**: Crear roles, políticas y OIDC providers
- **KMS**: Crear claves de encriptación
- **ECR**: Crear repositorios de contenedores
- **CloudWatch Logs**: Crear grupos de logs
- **ELB**: Load Balancers para servicios de Kubernetes
- **AutoScaling**: Grupos de auto-escalado para nodos EKS

## Verificar permisos

Después de aplicar la política, verifica que el usuario tiene los permisos:

```bash
aws iam list-attached-user-policies --user-name Terraform-admin
```

## Continuar con Terraform

Una vez aplicada la política, ejecuta:

```bash
cd terraform
terraform apply
```

Terraform debería poder crear todos los recursos sin errores de permisos.
