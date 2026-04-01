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

## UI 结构验证（坑位 / 字段 / 条件）

> 验证方式：静态代码验证
> 视觉验证：⚠️ 以下各项结构通过后，仍需人工 / 截图工具做视觉确认

<lark-table rows="5" cols="5" header-row="true">
  <lark-tr><lark-td>坑位 / 元素</lark-td><lark-td>坑位存在</lark-td><lark-td>字段绑定正确</lark-td><lark-td>条件渲染正确</lark-td><lark-td>事件挂载正确</lark-td></lark-tr>
  <lark-tr><lark-td>商品主图</lark-td><lark-td>✅ / ❌</lark-td><lark-td>✅ mainPic / ❌</lark-td><lark-td>always / ✅</lark-td><lark-td>tap→预览 ✅ / ❌</lark-td></lark-tr>
  <lark-tr><lark-td>促销角标</lark-td><lark-td>✅ / ❌</lark-td><lark-td>✅ tagName / ❌</lark-td><lark-td>tagName != null ✅ / ❌</lark-td><lark-td>无 ✅</lark-td></lark-tr>
  <lark-tr><lark-td>加购按钮</lark-td><lark-td>✅ / ❌</lark-td><lark-td>✅ / ❌ 字段缺失</lark-td><lark-td>canAddCart ✅ / ❌</lark-td><lark-td>tap→加购 ✅ / ❌</lark-td></lark-tr>
</lark-table>

### 状态变体检查

<lark-table rows="4" cols="3" header-row="true">
  <lark-tr><lark-td>状态</lark-td><lark-td>Reference 有此状态</lark-td><lark-td>Target 实现</lark-td></lark-tr>
  <lark-tr><lark-td>空列表</lark-td><lark-td>✅</lark-td><lark-td>✅ 有 empty 分支 / ❌ 缺失</lark-td></lark-tr>
  <lark-tr><lark-td>加载中</lark-td><lark-td>✅</lark-td><lark-td>✅ skeleton / ❌ 缺失</lark-td></lark-tr>
  <lark-tr><lark-td>错误/重试</lark-td><lark-td>✅</lark-td><lark-td>✅ / ❌ 缺失</lark-td></lark-tr>
</lark-table>

### 需人工视觉确认的坑位

以下坑位结构验证通过，但视觉正确性需运行后截图确认：

- [ ] 坑位名：原因（如：rpx 尺寸需对照设计稿；颜色由动态字段驱动）

以下坑位存在结构问题，应先修复再做视觉验证：

- [ ] 坑位名：问题描述（如：字段缺失 / 条件不匹配）

---

## 验证结论

**通过 / 存在问题**

如有问题，列出：
- 问题描述
- 涉及 CaseID
- 建议修复
