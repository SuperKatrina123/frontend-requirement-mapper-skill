# Diff Map Template

Use this template to record the **cross-repo structural diff** output (Stage 4) before Stage 5 mapping.

## 0. Tech stack snapshot

| 维度 | 参考端 | 目标端 | 备注 |
| --- | --- | --- | --- |
| Framework |  |  |  |
| Routing |  |  |  |
| State |  |  |  |
| API layer |  |  |  |
| BFF |  |  |  |
| Upstream service |  |  |  |
| Styling |  |  |  |
| Build/platform |  |  |  |

## 1. Directory convention map

| 层 | 参考端路径约定 | 目标端路径约定 | 备注 |
| --- | --- | --- | --- |
| Pages |  |  |  |
| Shared components |  |  |  |
| API |  |  |  |
| State |  |  |  |
| Routing |  |  |  |
| Types |  |  |  |

## 2. Module anchor table

Use `assets/module-anchor-template.md` or inline here:

| 功能模块 | 参考端 repo/path | 目标端 repo/path | 入口路由/页面 | 备注 | 置信度 |
| --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |

## 3. Diff map table

结论仅使用以下枚举：
- `直接复用`
- `小改`
- `需新增`
- `字段缺失`
- `待确认`

Change type:
- `UI-only`
- `Logic-only`
- `UI+Logic`

| 模块/坑位/能力点 | Change type | 初步结论 | 参考端证据（path:line） | 目标端证据（path:line） | 风险等级 | 责任侧 | 影响范围 | 待确认/阻塞项 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  | 高/中/低 | FE/BFF/BE/QA |  |  |
|  |  |  |  |  |  |  |  |  |

