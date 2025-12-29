# Martin Fowler's Refactoring Catalog

## Composing Methods

### Extract Method

**Problem**: Code fragment that can be grouped together.

```typescript
// Before
function printOwing() {
  printBanner();

  // Print details
  console.log("name: " + name);
  console.log("amount: " + getOutstanding());
}

// After
function printOwing() {
  printBanner();
  printDetails(getOutstanding());
}

function printDetails(outstanding: number) {
  console.log("name: " + name);
  console.log("amount: " + outstanding);
}
```

### Inline Method

**Problem**: Method body is as clear as its name.

```typescript
// Before
function getRating() {
  return moreThanFiveLateDeliveries() ? 2 : 1;
}

function moreThanFiveLateDeliveries() {
  return numberOfLateDeliveries > 5;
}

// After
function getRating() {
  return numberOfLateDeliveries > 5 ? 2 : 1;
}
```

### Extract Variable

**Problem**: Complex expression that is hard to understand.

```typescript
// Before
if (platform.toUpperCase().indexOf("MAC") > -1 &&
    browser.toUpperCase().indexOf("IE") > -1 &&
    wasInitialized() && resize > 0) {
  // ...
}

// After
const isMacOS = platform.toUpperCase().indexOf("MAC") > -1;
const isIE = browser.toUpperCase().indexOf("IE") > -1;
const wasResized = resize > 0;

if (isMacOS && isIE && wasInitialized() && wasResized) {
  // ...
}
```

### Replace Temp with Query

**Problem**: Temporary variable holds result of an expression.

```typescript
// Before
function calculateTotal() {
  const basePrice = quantity * itemPrice;
  if (basePrice > 1000) {
    return basePrice * 0.95;
  }
  return basePrice * 0.98;
}

// After
function calculateTotal() {
  if (basePrice() > 1000) {
    return basePrice() * 0.95;
  }
  return basePrice() * 0.98;
}

function basePrice() {
  return quantity * itemPrice;
}
```

---

## Moving Features

### Move Method

**Problem**: Method uses features of another class more than its own.

```java
// Before
class Account {
  double overdraftCharge() {
    if (type.isPremium()) {
      double result = 10;
      if (daysOverdrawn > 7) {
        result += (daysOverdrawn - 7) * 0.85;
      }
      return result;
    }
    return daysOverdrawn * 1.75;
  }
}

// After
class AccountType {
  double overdraftCharge(int daysOverdrawn) {
    if (isPremium()) {
      double result = 10;
      if (daysOverdrawn > 7) {
        result += (daysOverdrawn - 7) * 0.85;
      }
      return result;
    }
    return daysOverdrawn * 1.75;
  }
}

class Account {
  double overdraftCharge() {
    return type.overdraftCharge(daysOverdrawn);
  }
}
```

### Move Field

**Problem**: Field is used more by another class.

```typescript
// Before
class Customer {
  private discountRate: number;
}

class Order {
  getDiscountedPrice() {
    return basePrice * (1 - customer.discountRate);
  }
}

// After - Move discountRate to where it's used
class Order {
  private discountRate: number;

  getDiscountedPrice() {
    return basePrice * (1 - this.discountRate);
  }
}
```

### Extract Class

**Problem**: Class doing work of two.

```typescript
// Before
class Person {
  name: string;
  officeAreaCode: string;
  officeNumber: string;

  getTelephoneNumber() {
    return `(${this.officeAreaCode}) ${this.officeNumber}`;
  }
}

// After
class TelephoneNumber {
  areaCode: string;
  number: string;

  toString() {
    return `(${this.areaCode}) ${this.number}`;
  }
}

class Person {
  name: string;
  officeTelephone: TelephoneNumber;

  getTelephoneNumber() {
    return this.officeTelephone.toString();
  }
}
```

### Inline Class

**Problem**: Class isn't doing enough to justify its existence.

```typescript
// Before
class Person {
  name: string;
  officeTelephone: TelephoneNumber;

  getTelephoneNumber() {
    return this.officeTelephone.toString();
  }
}

class TelephoneNumber {
  areaCode: string;
  number: string;

  toString() {
    return `(${this.areaCode}) ${this.number}`;
  }
}

// After (if TelephoneNumber has no other behavior)
class Person {
  name: string;
  officeAreaCode: string;
  officeNumber: string;

  getTelephoneNumber() {
    return `(${this.officeAreaCode}) ${this.officeNumber}`;
  }
}
```

---

## Organizing Data

### Replace Magic Number with Symbolic Constant

```typescript
// Before
function potentialEnergy(mass: number, height: number) {
  return mass * 9.81 * height;
}

// After
const GRAVITATIONAL_CONSTANT = 9.81;

function potentialEnergy(mass: number, height: number) {
  return mass * GRAVITATIONAL_CONSTANT * height;
}
```

### Replace Data Value with Object

```typescript
// Before
class Order {
  customer: string; // Just a name
}

// After
class Customer {
  constructor(public name: string) {}
}

class Order {
  customer: Customer;
}
```

### Encapsulate Field

```typescript
// Before
class Person {
  name: string;
}

// After
class Person {
  private _name: string;

  get name() { return this._name; }
  set name(value: string) { this._name = value; }
}
```

---

## Simplifying Conditional Expressions

### Decompose Conditional

```typescript
// Before
if (date.before(SUMMER_START) || date.after(SUMMER_END)) {
  charge = quantity * winterRate + winterServiceCharge;
} else {
  charge = quantity * summerRate;
}

// After
if (isWinter(date)) {
  charge = winterCharge(quantity);
} else {
  charge = summerCharge(quantity);
}

function isWinter(date: Date) {
  return date.before(SUMMER_START) || date.after(SUMMER_END);
}

function winterCharge(quantity: number) {
  return quantity * winterRate + winterServiceCharge;
}

function summerCharge(quantity: number) {
  return quantity * summerRate;
}
```

### Consolidate Conditional Expression

```typescript
// Before
function disabilityAmount() {
  if (seniority < 2) return 0;
  if (monthsDisabled > 12) return 0;
  if (isPartTime) return 0;
  // Compute disability amount
}

// After
function disabilityAmount() {
  if (isNotEligibleForDisability()) return 0;
  // Compute disability amount
}

function isNotEligibleForDisability() {
  return seniority < 2 || monthsDisabled > 12 || isPartTime;
}
```

### Replace Nested Conditional with Guard Clauses

```typescript
// Before
function getPayAmount() {
  let result: number;
  if (isDead) {
    result = deadAmount();
  } else {
    if (isSeparated) {
      result = separatedAmount();
    } else {
      if (isRetired) {
        result = retiredAmount();
      } else {
        result = normalPayAmount();
      }
    }
  }
  return result;
}

// After
function getPayAmount() {
  if (isDead) return deadAmount();
  if (isSeparated) return separatedAmount();
  if (isRetired) return retiredAmount();
  return normalPayAmount();
}
```

### Replace Conditional with Polymorphism

```typescript
// Before
function getSpeed() {
  switch (type) {
    case 'european':
      return getBaseSpeed();
    case 'african':
      return getBaseSpeed() - getLoadFactor() * numberOfCoconuts;
    case 'norwegian_blue':
      return isNailed ? 0 : getBaseSpeed(voltage);
  }
}

// After
abstract class Bird {
  abstract getSpeed(): number;
}

class European extends Bird {
  getSpeed() { return getBaseSpeed(); }
}

class African extends Bird {
  getSpeed() { return getBaseSpeed() - getLoadFactor() * numberOfCoconuts; }
}

class NorwegianBlue extends Bird {
  getSpeed() { return isNailed ? 0 : getBaseSpeed(voltage); }
}
```

---

## Making Method Calls Simpler

### Rename Method

Choose a name that reveals the method's purpose.

```typescript
// Before
function getsnm() { return this.sn; }

// After
function getSecondName() { return this.secondName; }
```

### Introduce Parameter Object

```typescript
// Before
function amountInvoiced(start: Date, end: Date) { }
function amountReceived(start: Date, end: Date) { }
function amountOverdue(start: Date, end: Date) { }

// After
class DateRange {
  constructor(public start: Date, public end: Date) {}
}

function amountInvoiced(range: DateRange) { }
function amountReceived(range: DateRange) { }
function amountOverdue(range: DateRange) { }
```

### Replace Parameter with Method Call

```typescript
// Before
const basePrice = quantity * itemPrice;
const seasonDiscount = this.getSeasonalDiscount();
const finalPrice = discountedPrice(basePrice, seasonDiscount);

// After
const basePrice = quantity * itemPrice;
const finalPrice = discountedPrice(basePrice);

function discountedPrice(basePrice: number) {
  return basePrice * (1 - getSeasonalDiscount());
}
```

---

## Dealing with Generalization

### Pull Up Method

Move identical methods from subclasses to superclass.

### Push Down Method

Move method from superclass to relevant subclasses only.

### Extract Superclass

Create superclass for classes with common features.

### Extract Interface

Extract common operations into an interface.

### Replace Inheritance with Delegation

```typescript
// Before
class Stack<T> extends Vector<T> {
  push(item: T) { addElement(item); }
  pop(): T { return removeElementAt(size() - 1); }
}

// After
class Stack<T> {
  private vector: Vector<T> = new Vector();

  push(item: T) { this.vector.addElement(item); }
  pop(): T { return this.vector.removeElementAt(this.vector.size() - 1); }
}
```
