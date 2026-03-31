# QA 验证记录 — [功能名称]

> 验证时间：YYYY-MM-DD
> 验证范围：[证件类型 / 字段列表]
> 验证平台：[微信小程序 / H5 / 支付宝小程序 / 百度小程序 / 快应用]
> 验证方式：静态代码验证（对照实现逐条检查，未运行代码）

---

## [字段/证件类型 1]

校验函数：`functionName`
规则：`/regex/` 或文字描述

<lark-table rows="N" cols="4" header-row="true">
  <lark-tr><lark-td>CaseID</lark-td><lark-td>输入</lark-td><lark-td>预期</lark-td><lark-td>结果</lark-td></lark-tr>
  <lark-tr><lark-td>XXXXXXX</lark-td><lark-td>合法边界值（最小）</lark-td><lark-td>通过校验</lark-td><lark-td>✅ 通过</lark-td></lark-tr>
  <lark-tr><lark-td>XXXXXXX</lark-td><lark-td>合法边界值（最大）</lark-td><lark-td>通过校验</lark-td><lark-td>✅ 通过</lark-td></lark-tr>
  <lark-tr><lark-td>XXXXXXX</lark-td><lark-td>非法边界值（最小-1）</lark-td><lark-td>拦截提示</lark-td><lark-td>✅ 拦截</lark-td></lark-tr>
  <lark-tr><lark-td>XXXXXXX</lark-td><lark-td>非法边界值（最大+1）</lark-td><lark-td>拦截提示</lark-td><lark-td>✅ 拦截</lark-td></lark-tr>
  <lark-tr><lark-td>XXXXXXX</lark-td><lark-td>含中文</lark-td><lark-td>拦截提示</lark-td><lark-td>✅ 拦截</lark-td></lark-tr>
  <lark-tr><lark-td>XXXXXXX</lark-td><lark-td>含空格</lark-td><lark-td>拦截提示</lark-td><lark-td>✅ 拦截</lark-td></lark-tr>
  <lark-tr><lark-td>XXXXXXX</lark-td><lark-td>含特殊字符</lark-td><lark-td>拦截提示</lark-td><lark-td>✅ 拦截</lark-td></lark-tr>
  <lark-tr><lark-td>XXXXXXX</lark-td><lark-td>空/失焦</lark-td><lark-td>拦截提示</lark-td><lark-td>✅ 拦截</lark-td></lark-tr>
  <lark-tr><lark-td>XXXXXXX</lark-td><lark-td>全为空格</lark-td><lark-td>拦截提示</lark-td><lark-td>✅ 拦截</lark-td></lark-tr>
  <lark-tr><lark-td>XXXXXXX</lark-td><lark-td>首尾带空格的合法值</lark-td><lark-td>拦截提示</lark-td><lark-td>✅ 拦截</lark-td></lark-tr>
</lark-table>

---

## [字段/证件类型 2]

（重复上方结构）

---

## UI 层 maxlength 检查

<lark-table rows="3" cols="3" header-row="true">
  <lark-tr><lark-td>文件</lark-td><lark-td>条件 / 字段类型</lark-td><lark-td>结果</lark-td></lark-tr>
  <lark-tr><lark-td>`path/to/template.wxml`</lark-td><lark-td>maxlength=N（覆盖最长允许位数）</lark-td><lark-td>✅ 正常 / ❌ 截断风险</lark-td></lark-tr>
</lark-table>

---

## 验证结论

**通过 / 存在问题**

如有问题，列出：
- 问题描述
- 涉及 CaseID
- 建议修复
