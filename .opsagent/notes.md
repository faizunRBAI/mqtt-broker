# mqtt-broker — Working Notes

## Project summary
Self-hosted Mosquitto 2.x MQTT broker on EC2 t3.micro (Ubuntu 22.04).
Clients (ESP32 etc.) connect from any network via a static Elastic IP.

## Decisions
- **No ALB / no nginx** — Mosquitto binds ports 1883/8080 directly; no HTTP reverse proxy needed.
- **Port 8883 open in SG** — TLS not configured yet (no cert), but port reserved for future Let's Encrypt upgrade.
- **Docker delivery** — eclipse-mosquitto:2 official image; avoids apt repo pinning issues.
- **Elastic IP** — gives a stable address ESP32 firmware can hardcode; free while attached.
- **t3.micro** — well within Free Tier limits; Mosquitto is very lightweight.
- **Username/password auth** — allow_anonymous false; single `opsagent` user; password from MQTT_PASSWORD secret.
- **No managed DB / no RDS** — Mosquitto uses local file persistence in /opt/mosquitto/data (Docker volume mount).

## Secrets required
- `MQTT_PASSWORD` — set via set_pipeline_secret before deploy (alphanumeric, ≥20 chars)
- Platform-managed: SSH_PUBLIC_KEY, SSH_PRIVATE_KEY, SSH_USER, TF_STATE_BUCKET, PROJECT_NAME, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY

## Status
- [x] Architecture written
- [x] Pipeline written
- [x] Design approved
- [x] Plan approved
- [x] All files generated
- [ ] validate_project
- [ ] create_repo_and_push
- [ ] set_pipeline_secret MQTT_PASSWORD
- [ ] deploy
- [ ] wait_for_run

## Known gotchas
- The `instance_ip` output is the ephemeral public IP (pre-EIP); configure stage uses it for SSH.
  verify stage reads `elastic_ip` from terraform output directly (self-sufficient job rule).
- Password file is generated with `creates:` guard so it's idempotent; to rotate password,
  delete /opt/mosquitto/config/passwd on the host and re-run the playbook.
- Port 8883 (MQTTS) is open in the SG but Mosquitto has no TLS listener configured yet —
  connections to 8883 will be refused until certs are added.
