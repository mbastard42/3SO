rec {

  # GLOBAL
  HOST = "127.0.0.1";
  HTTPS_HOSTNAME = "preprod.local";

  # POSTGRES
  POSTGRES_PORT = "5432";
  POSTGRES_DB = "postgres";
  POSTGRES_USER = "postgres";
  POSTGRES_PASSWORD = "password";

  PG_BACKEND_DB = "mirror";
  PG_BACKEND_USER = "${PG_BACKEND_DB}";
  PG_BACKEND_PASSWORD = "symfony1234";
  PG_BACKEND_URL = "postgresql://${PG_BACKEND_USER}:${PG_BACKEND_PASSWORD}@${HOST}:${POSTGRES_PORT}/${PG_BACKEND_DB}?serverVersion=16&charset=utf8";

  PG_ADMIN_DB = "truth";
  PG_ADMIN_USER = "${PG_ADMIN_DB}";
  PG_ADMIN_PASSWORD = "odoo1234";

  # MINIO
  MINIO_API_PORT = "9000";

  MINIO_ROOT_USER = "admin";
  MINIO_ROOT_PASSWORD = "password123";
  MINIO_ENDPOINT = "http://${HOST}:${MINIO_API_PORT}";
  MINIO_INTERNAL_ENDPOINT = "http://localhost:${MINIO_API_PORT}";

  MINIO_ADMIN_USER = "adminuser";
  MINIO_ADMIN_BUCKET = "truth";
  MINIO_ADMIN_PASSWORD = "truthpassword";

  MINIO_BACKEND_USER = "backenduser";
  MINIO_BACKEND_BUCKET = "mirror";
  MINIO_BACKEND_PASSWORD = "mirrorpassword";

  # ODOO
  ODOO_ENDPOINT = "http://${HOST}:8069";
  ODOO_USER = "admin";
  ODOO_PASSWORD = "password";
}
