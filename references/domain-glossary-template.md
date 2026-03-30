# Business Glossary Template

Use this template when the project has many business-specific names that do not map cleanly to code.

## Recommended usage

Provide this glossary before requirement analysis when possible.

Good sources:
- old requirement docs
- product terminology docs
- onboarding notes
- your own running notes from previous demands

## Template

| 业务词 | 别名/简称 | 代码中可能的关键词 | 含义说明 | 常见字段 | 备注 |
| --- | --- | --- | --- | --- | --- |
| 坑位 | slot, position, module, floor | slot, position, module, floor, card | 页面上的运营展示位 | slotId, positionCode | 不同团队命名不一致 |
| 金刚区 | 宫格区, 服务区 | kingkong, grid, shortcut | 首页入口宫格 | icon, title, jumpUrl | 有时属于 banner 容器的一部分 |
| 楼层 | block, module | floor, block, section | 页面中的一整块内容区域 | floorId, floorType | 可能包含多个坑位 |

## Minimal rule set

- One row per term
- Prefer code-searchable aliases
- Distinguish business meaning from UI appearance
- If a term maps to multiple technical concepts, split it into multiple rows
