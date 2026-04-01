# Module Anchor Table

Use this table to lock down **where** each in-scope functional module lives in both repos before running structural diff.

Rules:
- One row per functional module (page / module / slot group).
- Prefer **developer-provided paths** over agent-discovered paths.
- Paths can be directories or files; use the smallest stable anchor.
- If uncertain, mark as `待确认` and add candidate paths.

| 功能模块 | 参考端 repo/path | 目标端 repo/path | 入口路由/页面 | 备注 | 置信度 |
| --- | --- | --- | --- | --- | --- |
| 商品详情页 | `<ref>/src/screens/Product/Detail/` | `<target>/src/pages/goods/detail/` | `/product/detail?id=` | | 高/中/低 |
|  |  |  |  |  |  |

