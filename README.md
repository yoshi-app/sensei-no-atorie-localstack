# 先生のアトリエ サーバー構築

Vercel + Upstash 構成から AWS 構成への移行プロジェクト。

## アーキテクチャ

```
インターネット
    ↓
Route 53（ドメイン管理）
    ↓
EC2（Webサーバー + APIサーバー / Node.js）
    ├── ElastiCache Redis（レート制限：1日5回）
    ├── Gemini API（授業活動の生成）
    └── RDS PostgreSQL（生成データの保存）
```

## 移行の設計意図

| 観点 | 内容 |
|---|---|
| 可観測性の向上 | CloudWatch 等によるメトリクス・ログの一元管理 |
| DB 永続化 | 生成した授業活動データを RDS PostgreSQL に蓄積 |
| スケーラビリティの確保 | ElastiCache を EC2 から分離し、将来のマルチ EC2 構成でも整合性を維持 |

## 移行前後の対応表

| 機能 | 移行前 | 移行後 |
|---|---|---|
| API・Webサーバー | Vercel Serverless Functions | EC2（Node.js） |
| レート制限ストア | Upstash Redis | ElastiCache Redis |
| データ永続化 | なし | RDS PostgreSQL |
| ドメイン管理 | Vercel | Route 53 |

## 前提条件

| ツール | バージョン |
|---|---|
| Docker | 29.1.3 |
| AWS CLI | 2.31.35 |
| LocalStack CLI | 2026.4.0 |
| LocalStack Auth Token | [app.localstack.cloud](https://app.localstack.cloud) で取得 |

## LocalStack 起動

```bash
export LOCALSTACK_AUTH_TOKEN=your-token
localstack start
```

## 関連リポジトリ

- アプリ本体: https://github.com/yoshi-app/sensei-no-atorie
