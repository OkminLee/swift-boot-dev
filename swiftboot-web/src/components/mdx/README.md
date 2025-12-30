# MDX 커스텀 컴포넌트 가이드

레슨 콘텐츠에서 사용할 수 있는 커스텀 컴포넌트입니다.

## 사용 가능한 컴포넌트

### 1. Hint (힌트)

접기/펼치기 가능한 힌트 박스입니다.

```markdown
:::hint{title="힌트 제목"}
힌트 내용을 여기에 작성합니다.
:::
```

### 2. Warning (경고)

주의사항을 표시하는 경고 박스입니다.

```markdown
:::warning{title="주의"}
주의해야 할 내용을 작성합니다.
:::
```

### 3. Info (정보)

추가 정보를 표시하는 정보 박스입니다.

```markdown
:::info{title="참고"}
참고할 정보를 작성합니다.
:::
```

### 4. Note (노트)

Info와 동일하지만 기본 제목이 "노트"입니다.

```markdown
:::note
노트 내용을 작성합니다.
:::
```

## 코드 블록

코드 블록은 자동으로 복사 버튼이 추가됩니다.

````markdown
```swift
print("Hello, World!")
```
````

## 예시

```markdown
# 변수 선언하기

Swift에서 변수를 선언하는 방법을 배워봅시다.

:::info{title="Swift란?"}
Swift는 Apple이 만든 현대적인 프로그래밍 언어입니다.
:::

```swift
var name = "SwiftBoot"
print(name)
```

:::warning{title="주의"}
변수 이름은 숫자로 시작할 수 없습니다!
:::

:::hint{title="막히면 클릭!"}
`var` 키워드를 사용해서 변수를 선언하세요.
:::
```
