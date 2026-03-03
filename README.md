```mermaid
erDiagram

    Categories ||--o{ Games : has
    Games ||--o{ CartItems : added_to
    Games ||--o{ Purchases : purchased
    AspNetUsers ||--o{ CartItems : owns
    AspNetUsers ||--o{ Purchases : makes

    AspNetRoles ||--o{ AspNetRoleClaims : contains
    AspNetRoles ||--o{ AspNetUserRoles : assigned
    AspNetUsers ||--o{ AspNetUserRoles : has
    AspNetUsers ||--o{ AspNetUserClaims : has
    AspNetUsers ||--o{ AspNetUserLogins : has
    AspNetUsers ||--o{ AspNetUserTokens : has
```
