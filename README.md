# Frontend Requirement Mapper Skill

`frontend-requirement-mapper` 是一个面向前端需求全生命周期的 Agent Skill，覆盖从 PRD 澄清到开发完成后 QA 闭环的完整工作流：

```
PRD 澄清 → Spec 归一化 → 参考 APP 逆向 → 跨仓库结构 Diff → 目标项目映射 → 防遗漏检查 → 报告输出 → QA 静态验证
```

适合处理这类工作：
- PRD 描述不清，需要先澄清真实需求
- PRD 不够标准，需要先整理成开发可执行的 Spec
- 需要参考 `追齐APP` 或其他参考端的实际代码行为
- 需要在映射前先做两个仓库之间的结构性 Diff，全面掌握差异范围
- 两个仓库技术栈不同（如 React vs 小程序 WXML），需要做语义级对比而非语法级对比
- 需要逐页面、逐坑位、逐字段地映射到目标项目
- 需要输出可用于评审的前端需求分析或技术方案初稿
- 开发完成后，需要对照 test cases 做前端校验逻辑的静态 QA 验证

## 仓库结构

```text
.
├── SKILL.md
├── assets/
│   ├── qa-record-template.md         # QA 验证结果记录模板
│   ├── requirement-analysis-template.md
│   └── spec-template.md
├── references/
│   ├── checklist.md                  # 防遗漏检查清单
│   ├── domain-glossary-template.md
│   ├── qa-playbook.md                # QA 静态验证方法论
│   ├── repo-diff-playbook.md         # 跨仓库结构 Diff 方法（含跨栈语义 Diff）
│   ├── search-playbook.md
│   ├── spec-gap-checklist.md
│   └── workflow.md
└── scripts/
    └── scaffold_report.sh
```

## 适用场景

- 阅读 PRD 后快速拆解功能点、待确认项和风险点
- 在需求不标准时，先生成一份开发侧 Spec 初稿
- 扒参考 APP 或参考仓库，确认页面、坑位、展示条件和字段使用
- **在进入目标项目映射前，先做跨仓库结构 Diff**，全量掌握差异范围（不只看 PRD 提到的点）
- 针对 React vs 小程序 WXML 等跨栈场景，做语义级 UI 对比（坑位 / 字段 / 条件），而不是无意义的语法对比
- 对照多个前端仓库，判断主仓库、联动仓库和改造范围
- 输出结构化分析文档，减少遗漏

## 安装方式

把整个 skill 目录放到目标项目的 `.agents/skills/frontend-requirement-mapper/` 下：

```text
your-project/
  .agents/
    skills/
      frontend-requirement-mapper/
        SKILL.md
        references/
        assets/
        scripts/
```

如果你只是本地先试，也可以把这个仓库当作独立 skill 目录使用。

## 如何触发

推荐在 Codex 中显式点名使用：

```text
请使用 frontend-requirement-mapper skill 分析这次需求。
参考对象是追齐APP。
主仓库是 /abs/path/repo-a
联动仓库有：
- /abs/path/repo-b

业务代码位置（可选，提供后跳过模块发现阶段）：
- 参考端：src/screens/Product/Detail/，src/components/Card/
- 目标端：src/pages/goods/detail/，src/components/goods-card.vue

请先输出：
1. 已明确
2. 待确认
3. 潜在风险
4. 下一步建议搜索的页面、模块、字段关键词
```

## 你最好准备的输入

### 必需

- PRD
- 参考对象
- 主仓库路径

### 推荐

- 可能联动的仓库路径
- **业务代码位置**：本次需求涉及的文件或目录（参考端和目标端各自在哪），提供后 agent 跳过模块发现阶段，直接开始 diff
- 常见业务词解释
- 你已经怀疑的页面、模块、接口、字段

### 加分

- 历史需求文档
- 旧方案文档
- 输出文档路径

## 跨仓库 Diff 说明

Skill 在参考 APP 逆向完成后、进入目标项目映射前，会执行一个独立的 **跨仓库结构 Diff** 阶段。

这个阶段不是语法对比，而是：

1. **Pre-flight 准备**：技术栈快照 + 目录约定对比 + 模块锚点声明（每个功能模块在两个仓库里各在哪）
2. **结构 Diff**：目录 / 路由 / 组件树 / API / 状态层逐层对比
3. **跨栈语义 Diff**：当两端技术栈不同（如 React vs 小程序 WXML）时，提取双方的 UI contract（坑位 → 字段 → 可见性条件 → 交互），对比 contract 而不是代码；同时输出字段名映射表（`imageUrl → mainPic`），标注 `字段缺失`
4. **Diff Map**：产出模块级差异表（变更类型 `UI-only / Logic-only / UI+Logic` + 初步分类），作为映射阶段的输入

详见 [`references/repo-diff-playbook.md`](references/repo-diff-playbook.md)。



这个 skill 支持多仓库场景，但不建议一上来把所有仓库混在一起分析。

更稳的方式是：
- 先告诉 Agent 这次需求涉及哪些仓库
- 明确主仓库
- 标出哪些仓库只是联动检查
- 最后再做跨仓汇总

推荐输入格式：

```md
这次需求涉及多个仓库：

| 仓库 | 路径 | 技术栈 | 负责范围 | 优先级 |
| --- | --- | --- | --- | --- |
| h5-main | /abs/path/h5-main | React + TS | 主站页面 | 高 |
| activity-web | /abs/path/activity-web | Vue + TS | 活动页/运营页 | 高 |
| shared-ui | /abs/path/shared-ui | React | 公共组件库 | 中 |
```

## 业务词怎么提供

如果 PRD、代码和团队口径里的业务词不一致，建议提前给一份简单词典。

例如：
- `坑位 = slot / position / module / floor`
- `金刚区 = kingkong / grid / shortcut`
- `楼层 = floor / block / section`

可以参考 [`references/domain-glossary-template.md`](references/domain-glossary-template.md)。

## 实践建议

### 第一次实践怎么跑

第一次不要追求“大而全”，建议先跑一轮最小闭环：

1. 给 PRD
2. 告诉 Agent 参考对象是不是 `追齐APP`
3. 给主仓库路径
4. 如果有，再给 1 到 2 个联动仓库
5. 再补 2 到 5 个关键业务词

第一轮只要求输出：
- `已明确`
- `待确认`
- `潜在风险`
- `Spec 初稿`
- `建议搜索关键词`

等第一轮靠谱，再让它继续做参考 APP 盘点和目标项目映射。

### 如果你准备不充分怎么办

如果你只给了 PRD，Skill 仍然可以开始工作，但通常会先做：
- 需求拆解
- 模糊点识别
- 风险提示
- Spec 缺口识别
- 下一步缺失信息清单

只有当不确定性会影响这些判断时，才应该回头向你确认：
- 该看哪个端
- 主仓库是哪个
- 参考 APP 的哪个页面才是正确对照对象
- 两个字段是否语义等价

如果只是普通信息缺失，应该继续推进，并把内容标成 `待确认`。

### 建议长期维护的两类信息

如果你经常做这类需求，建议逐步沉淀：
- `repo manifest`
  记录端、仓库、技术栈、负责范围、路径
- `business glossary`
  记录业务词、别名、代码关键词、字段含义

它们不需要一次性整理完整，可以每次需求做完后顺手补一两条。

### 不要让 Agent 做的事

- 不要让它在仓库不明确时直接给最终方案
- 不要让它把推测当事实写进文档
- 不要让它只看 UI 层文件就下结论
- 不要让它一次性全扫所有仓库

## 产物

Skill 最终建议输出一份结构化 Markdown 文档，可基于模板生成：

```bash
bash scripts/scaffold_report.sh path/to/output.md
```

模板位于 [`assets/requirement-analysis-template.md`](assets/requirement-analysis-template.md)。

如果 PRD 不够规范，建议先额外产出一份 Spec 初稿，模板位于 [`assets/spec-template.md`](assets/spec-template.md)，缺口检查清单位于 [`references/spec-gap-checklist.md`](references/spec-gap-checklist.md)。

## 相关资源

- Skill 入口说明：[`SKILL.md`](SKILL.md)
- 工作流：[`references/workflow.md`](references/workflow.md)
- 跨仓库 Diff 方法论：[`references/repo-diff-playbook.md`](references/repo-diff-playbook.md)
- 代码检索策略：[`references/search-playbook.md`](references/search-playbook.md)
- Spec 模板：[`assets/spec-template.md`](assets/spec-template.md)
- Spec 缺口清单：[`references/spec-gap-checklist.md`](references/spec-gap-checklist.md)
- 防遗漏清单：[`references/checklist.md`](references/checklist.md)
- 业务词典模板：[`references/domain-glossary-template.md`](references/domain-glossary-template.md)
- QA 静态验证方法论：[`references/qa-playbook.md`](references/qa-playbook.md)
- QA 验证记录模板：[`assets/qa-record-template.md`](assets/qa-record-template.md)
