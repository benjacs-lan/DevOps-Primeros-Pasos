# GitHub OIDC Setup Guide

Esta guía explica cómo configurar autenticación sin credenciales entre GitHub Actions y AWS usando OIDC (OpenID Connect).

## ¿Por qué OIDC?

**Ventajas sobre Access Keys:**

- ✅ **Más seguro**: No hay credenciales estáticas que puedan filtrarse
- ✅ **Sin rotación**: No necesitas rotar claves periódicamente
- ✅ **Auditable**: AWS CloudTrail registra quién asumió el rol
- ✅ **Granular**: Puedes limitar por repositorio, rama, etc.

## Pasos de Configuración

### 1. Obtener tu AWS Account ID

```bash
aws sts get-caller-identity --query Account --output text
```

Guarda este número, lo necesitarás en el paso 3.

### 2. Crear la infraestructura OIDC con Terraform

El archivo `terraform/github-oidc.tf` ya está creado. Ahora ejecuta:

```bash
cd terraform
terraform init
terraform apply
```

Esto creará:

- **OIDC Provider**: Conexión de confianza entre GitHub y AWS
- **IAM Role**: `github-actions-role` con permisos para ECR y EKS
- **Policies**: Permisos necesarios para el CI/CD

Al finalizar, Terraform mostrará el ARN del rol. Cópialo.

### 3. Actualizar el workflow de GitHub

Edita `.github/workflows/cicd.yaml` y reemplaza `YOUR_AWS_ACCOUNT_ID` con tu Account ID real:

```yaml
role-to-assume: arn:aws:iam::123456789012:role/github-actions-role
```

### 4. Verificar permisos del workflow

Asegúrate de que el job tenga estos permisos (ya está configurado):

```yaml
permissions:
  id-token: write # Necesario para obtener el token OIDC
  contents: read # Para hacer checkout del código
```

### 5. Probar el workflow

Haz un commit y push:

```bash
git add .
git commit -m "Configure OIDC authentication"
git push origin master
```

El workflow debería ejecutarse sin pedir credenciales.

## Troubleshooting

### Error: "Not authorized to perform sts:AssumeRoleWithWebIdentity"

**Causa**: El repositorio en el assume_role_policy no coincide.

**Solución**: Verifica que en `github-oidc.tf` el repositorio sea correcto:

```hcl
"token.actions.githubusercontent.com:sub" = "repo:benjacs-lan/DevOps-Primeros-Pasos:*"
```

### Error: "No OpenIDConnect provider found"

**Causa**: El OIDC provider no se creó correctamente.

**Solución**: Verifica que `terraform apply` se ejecutó sin errores.

## Seguridad Adicional

Para mayor seguridad, puedes restringir el rol a una rama específica:

```hcl
Condition = {
  StringEquals = {
    "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
    "token.actions.githubusercontent.com:sub" = "repo:benjacs-lan/DevOps-Primeros-Pasos:ref:refs/heads/master"
  }
}
```

## Referencias

- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [AWS IAM OIDC](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
