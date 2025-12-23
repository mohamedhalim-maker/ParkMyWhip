# Documentation Structure Overview

## 📂 Folder Organization

```
docs/
├── README.md                          # Main documentation index and quick start
├── SUMMARY.md                         # Overview of all documentation files
├── STRUCTURE.md                       # This file - visual structure guide
├── core.md                            # Core module (shared infrastructure)
├── state-management.md                # Cubit pattern and state management
├── data-layer.md                      # Data models and serialization
├── supabase-integration.md            # Backend integration guide
└── features/
    ├── auth-feature.md                # Authentication system
    └── home-feature.md                # Dashboard and main features
```

---

## 🗺️ Documentation Map

```
┌─────────────────────────────────────────────────────────────┐
│                      START HERE                              │
│                    docs/README.md                            │
│  (Navigation hub + Quick start + Key concepts)              │
└──────────────────┬──────────────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ▼                     ▼
┌──────────────┐      ┌──────────────┐
│ New to       │      │ Experienced  │
│ Project?     │      │ Developer?   │
└──────┬───────┘      └──────┬───────┘
       │                     │
       ▼                     │
┌──────────────────┐         │
│ architecture.md  │         │
│ (High-level)     │         │
└──────┬───────────┘         │
       │                     │
       └──────┬──────────────┘
              │
    ┌─────────┴─────────┐
    │                   │
    ▼                   ▼
┌─────────┐     ┌──────────────┐
│ CORE    │     │ FEATURES     │
│ SYSTEM  │     │              │
└────┬────┘     └──────┬───────┘
     │                 │
     │                 │
┌────┴───────────────┐ │
│                    │ │
▼                    ▼ ▼
┌──────────────┐  ┌──────────────────┐
│ core.md      │  │ features/        │
│              │  │ ├── auth         │
│ - Constants  │  │ └── home         │
│ - Widgets    │  │                  │
│ - Routes     │  │                  │
│ - Services   │  │                  │
└──────────────┘  └──────────────────┘
                  
┌──────────────────┐  ┌──────────────────┐
│ state-mgmt.md    │  │ data-layer.md    │
│                  │  │                  │
│ - Cubit pattern  │  │ - Models         │
│ - State design   │  │ - Serialization  │
│ - UI integration │  │ - Data sources   │
└──────────────────┘  └──────────────────┘

┌────────────────────────────────┐
│ supabase-integration.md        │
│                                │
│ - Setup                        │
│ - Database schema              │
│ - Auth flows                   │
│ - Query patterns               │
└────────────────────────────────┘
```

---

## 📚 Document Relationships

### Core Infrastructure
```
core.md
├── Used by → All features
├── References → architecture.md
└── Related to → state-management.md (for widgets using state)
```

### State Management
```
state-management.md
├── Used by → All features
├── Depends on → core.md (GetIt injection)
├── Related to → data-layer.md (models in state)
└── Examples from → features/*.md
```

### Data Layer
```
data-layer.md
├── Used by → All features
├── Related to → supabase-integration.md
├── Depends on → core.md (networking utilities)
└── Referenced by → features/*.md
```

### Backend Integration
```
supabase-integration.md
├── Used by → data-layer.md
├── Used by → features/auth-feature.md
└── Related to → core.md (services)
```

### Feature Documentation
```
features/auth-feature.md
├── Uses → core.md (widgets, routes)
├── Uses → state-management.md (AuthCubit)
├── Uses → data-layer.md (models)
└── Uses → supabase-integration.md (auth)

features/home-feature.md
├── Uses → core.md (widgets, routes)
├── Uses → state-management.md (multiple cubits)
├── Uses → data-layer.md (models)
└── Uses → supabase-integration.md (queries)
```

---

## 🎯 Use Case to Documentation Mapping

### "I want to add a new feature"
```
1. Read: architecture.md (understand structure)
2. Read: state-management.md (learn Cubit pattern)
3. Read: core.md (reusable widgets)
4. Read: data-layer.md (model patterns)
5. Reference: features/*.md (similar examples)
```

### "I want to style my UI"
```
1. Read: core.md → Constants section
2. Reference: features/*.md (UI examples)
```

### "I want to add a database table"
```
1. Read: supabase-integration.md → Database Schema
2. Read: data-layer.md → Model Structure
3. Update: supabase_tables.sql, supabase_policies.sql
```

### "I want to implement authentication"
```
1. Read: features/auth-feature.md (complete flows)
2. Read: supabase-integration.md → Authentication
3. Reference: data-layer.md (user models)
```

### "I want to manage component state"
```
1. Read: state-management.md (Cubit pattern)
2. Read: core.md (DI with GetIt)
3. Reference: features/*.md (examples)
```

### "I need to handle errors"
```
1. Read: core.md → Networking → NetworkExceptions
2. Read: supabase-integration.md → Error Handling
3. Reference: features/auth-feature.md (error handling examples)
```

---

## 🔄 Documentation Flow by Developer Role

### Frontend Developer
```
START
  ↓
README.md (overview)
  ↓
core.md (styling, widgets)
  ↓
state-management.md (UI state)
  ↓
features/*.md (feature implementation)
```

### Backend Developer
```
START
  ↓
README.md (overview)
  ↓
supabase-integration.md (database, auth)
  ↓
data-layer.md (models, queries)
  ↓
features/*.md (feature requirements)
```

### Full-Stack Developer
```
START
  ↓
README.md (overview)
  ↓
architecture.md (big picture)
  ↓
┌─────────────┬─────────────┐
│ core.md     │ data-layer.md│
│ state-mgmt  │ supabase     │
└─────────────┴─────────────┘
  ↓
features/*.md (implementation)
```

---

## 📖 Reading Order Recommendations

### Beginner (New to Project)
1. `README.md` - Start here!
2. `../architecture.md` - High-level overview
3. `core.md` - Learn shared components
4. `state-management.md` - Understand state flow
5. `features/auth-feature.md` - Study a complete feature
6. Other docs as needed

### Intermediate (Adding Features)
1. `state-management.md` - Refresh on patterns
2. `data-layer.md` - Model structure
3. `features/*.md` - Similar feature examples
4. `core.md` - Reusable components
5. `supabase-integration.md` - Database queries

### Advanced (Architecture Changes)
1. `../architecture.md` - Current architecture
2. `SUMMARY.md` - All docs overview
3. All relevant docs for changed areas
4. Update docs after changes

---

## 🗂️ Content Summary

| Document | Pages | Primary Audience | Update Frequency |
|----------|-------|------------------|------------------|
| README.md | ~8 | All developers | Medium |
| SUMMARY.md | ~4 | Maintainers | Low |
| STRUCTURE.md | ~4 | New developers | Low |
| core.md | ~25 | Frontend developers | Medium |
| state-management.md | ~30 | All developers | Low |
| data-layer.md | ~30 | Backend/Full-stack | Medium |
| supabase-integration.md | ~30 | Backend/Full-stack | Medium |
| features/auth-feature.md | ~25 | Feature developers | High |
| features/home-feature.md | ~30 | Feature developers | High |

---

## 🔍 Search Quick Reference

### Find Information About...

**Colors/Styling**
→ `core.md` → Constants → Colors

**State Management**
→ `state-management.md` → Cubit Structure Pattern

**Database Queries**
→ `supabase-integration.md` → Database Operations

**Data Models**
→ `data-layer.md` → Core Models

**Authentication**
→ `features/auth-feature.md` → User Flows

**Navigation**
→ `core.md` → Routes

**Error Handling**
→ `core.md` → Networking OR `supabase-integration.md` → Error Handling

**Form Validation**
→ `features/auth-feature.md` → Domain Layer → Validators

**Widgets**
→ `core.md` → Widgets OR `features/*.md` → Key Widgets

**Dependency Injection**
→ `core.md` → Config → Dependency Injection

---

## 🔄 Update Workflow

```
Code Change
    ↓
Identify affected docs
    ↓
Update primary docs
    ↓
Update cross-references
    ↓
Update SUMMARY.md (if needed)
    ↓
Update architecture.md (if structural)
    ↓
Commit with docs
```

---

## 📝 Documentation Standards

All documentation follows these standards:

✅ **Structure**:
- Clear hierarchy with H2/H3 headings
- Code examples for all patterns
- Cross-references to related docs

✅ **Content**:
- Practical examples
- Real code from the project
- Best practices and anti-patterns
- When to use each approach

✅ **Format**:
- Markdown with code syntax highlighting
- Tables for comparison
- Diagrams for flow/architecture
- Emoji for visual scanning 📚

---

## 🎓 Learning Paths

### Path 1: UI Development
```
1. README.md (overview)
2. core.md (constants, widgets)
3. state-management.md (Cubit basics)
4. features/home-feature.md (UI examples)
```

### Path 2: Business Logic
```
1. README.md (overview)
2. state-management.md (complete guide)
3. data-layer.md (models)
4. features/auth-feature.md (logic examples)
```

### Path 3: Backend Integration
```
1. README.md (overview)
2. supabase-integration.md (complete guide)
3. data-layer.md (serialization)
4. features/auth-feature.md (auth flows)
```

### Path 4: Full Feature
```
1. architecture.md (structure)
2. state-management.md (state patterns)
3. data-layer.md (models)
4. core.md (reusable components)
5. features/*.md (complete examples)
6. supabase-integration.md (backend)
```

---

**Last Updated**: March 2025

This structure guide helps navigate the comprehensive ParkMyWhip documentation.
