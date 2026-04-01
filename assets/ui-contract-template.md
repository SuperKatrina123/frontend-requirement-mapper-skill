# UI Contract Template (Cross-stack Friendly)

Use this when the reference and target repos use incompatible UI syntaxes (e.g. React vs WXML / RN vs miniapp).

The stable cross-stack anchor is the **visual semantic path**:

```
页面名 > 区块名 > 元素名
```

## A. Reference UI contract

| 视觉语义路径 | 渲染条件 | 驱动字段（参考端） | 交互 | 埋点 | 证据（path:line） |
| --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |

## B. Target UI contract

| 视觉语义路径 | 渲染条件 | 驱动字段（目标端） | 交互 | 埋点 | 证据（path:line） |
| --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |

## C. Contract diff (align by visual semantic path)

| 视觉语义路径 | 参考端字段/结构 | 目标端字段/结构 | 元素存在？ | Gap 类型 | 初步结论 | 待确认/阻塞项 |
| --- | --- | --- | --- | --- | --- | --- |
|  |  |  | 两端均有/目标缺失/参考缺失 | 字段名映射/字段结构差异/条件差异/缺失 | 直接复用/小改/需新增/字段缺失/待确认 |  |

