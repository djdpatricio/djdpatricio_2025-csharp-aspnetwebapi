/*
    DJDPatricio Insurance Management System (IMS) database script
    ----------------------------------------------------------------
    Builds the djdpatricio_ims database used by DJDPatricio.IMS.API: schemas, tables with
    primary keys, foreign keys and indexes, sequences, functions, views, the 58 stored procedures
    the API calls (plus one internal helper), every row of the unit test mock data, and a larger
    set of generated demo data (Philippine addresses, people, partners and about three years of bookings).

    Target: SQL Server 2019 or later, or Azure SQL Database. All timestamps are UTC (datetime2).

    How to run, top to bottom in one go:
        Own server or LocalDB:  sqlcmd -S <server> -E -b -I -i djdpatricio_ims.sql
        Hosted database (Azure SQL Database or a managed host where CREATE DATABASE and USE are not allowed):
            create the empty database in the host's portal, connect to it, delete or skip the block marked
            "SKIP ON A HOSTED DATABASE" below, and run the rest. Nothing after that block names a database.
    Then point ConnectionStrings:DefaultConnection in appsettings.json at that database.

    Safe to re-run: existing tables and rows are kept, functions, views and procedures are recreated,
    seed rows are only inserted when their Id (or the demo data marker) is missing.
    Generated demo dates are relative to the day the script first runs, so the dashboards always have recent data.
*/

SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

/* ---------- SKIP ON A HOSTED DATABASE: start ---------- */
IF DB_ID(N'djdpatricio_ims') IS NULL
    CREATE DATABASE [djdpatricio_ims];
GO

USE [djdpatricio_ims];
GO
/* ---------- SKIP ON A HOSTED DATABASE: end ---------- */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF SCHEMA_ID(N'Static') IS NULL EXEC (N'CREATE SCHEMA [Static] AUTHORIZATION [dbo];');
IF SCHEMA_ID(N'Reference') IS NULL EXEC (N'CREATE SCHEMA [Reference] AUTHORIZATION [dbo];');
IF SCHEMA_ID(N'Transaction') IS NULL EXEC (N'CREATE SCHEMA [Transaction] AUTHORIZATION [dbo];');
GO

/* =====================================================================
   Static: address hierarchy and fixed lookups (ids match StaticDataHelper)
   ===================================================================== */

IF OBJECT_ID(N'[Static].[AddressRegion]', N'U') IS NULL
CREATE TABLE [Static].[AddressRegion]
(
    [Id]               bigint        NOT NULL,
    [Name]             nvarchar(100) NOT NULL,
    [Code]             nvarchar(10)  NOT NULL,
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_AddressRegion_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_AddressRegion_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_AddressRegion_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_AddressRegion] PRIMARY KEY CLUSTERED ([Id])
);
GO

IF OBJECT_ID(N'[Static].[AddressRegionDivision]', N'U') IS NULL
CREATE TABLE [Static].[AddressRegionDivision]
(
    [Id]               bigint        NOT NULL,
    [AddressRegionId]  bigint        NOT NULL,
    [Name]             nvarchar(100) NOT NULL,
    [Code]             nvarchar(10)  NOT NULL,
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_AddressRegionDivision_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_AddressRegionDivision_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_AddressRegionDivision_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_AddressRegionDivision] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_AddressRegionDivision_AddressRegion] FOREIGN KEY ([AddressRegionId]) REFERENCES [Static].[AddressRegion] ([Id]),
    INDEX [IX_AddressRegionDivision_AddressRegionId] NONCLUSTERED ([AddressRegionId])
);
GO

IF OBJECT_ID(N'[Static].[AddressCountry]', N'U') IS NULL
CREATE TABLE [Static].[AddressCountry]
(
    [Id]                      bigint        NOT NULL,
    [AddressRegionDivisionId] bigint        NOT NULL,
    [Name]                    nvarchar(100) NOT NULL,
    [Code]                    nvarchar(10)  NOT NULL,
    [PhoneCode]               nvarchar(10)  NOT NULL,
    [TopLevelDomain]          nvarchar(10)  NOT NULL,
    [Currency]                nvarchar(10)  NOT NULL,
    [CurrencyName]            nvarchar(50)  NOT NULL,
    [Nationality]             nvarchar(50)  NOT NULL,
    [CreatedBy]               bigint        NULL,
    [CreatedDateTime]         datetime2(7)  NOT NULL CONSTRAINT [DF_AddressCountry_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]              bigint        NULL,
    [ModifiedDateTime]        datetime2(7)  NOT NULL CONSTRAINT [DF_AddressCountry_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]               bigint        NULL,
    [DeletedDateTime]         datetime2(7)  NULL,
    [IsDeleted]               bit           NOT NULL CONSTRAINT [DF_AddressCountry_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_AddressCountry] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_AddressCountry_AddressRegionDivision] FOREIGN KEY ([AddressRegionDivisionId]) REFERENCES [Static].[AddressRegionDivision] ([Id]),
    CONSTRAINT [UQ_AddressCountry_Code] UNIQUE ([Code]),
    INDEX [IX_AddressCountry_AddressRegionDivisionId] NONCLUSTERED ([AddressRegionDivisionId])
);
GO

IF OBJECT_ID(N'[Static].[AddressCountryDivision]', N'U') IS NULL
CREATE TABLE [Static].[AddressCountryDivision]
(
    [Id]               bigint        NOT NULL,
    [AddressCountryId] bigint        NOT NULL,
    [Name]             nvarchar(100) NOT NULL,
    [Acronym]          nvarchar(20)  NOT NULL,
    [Code]             nvarchar(10)  NOT NULL,
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_AddressCountryDivision_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_AddressCountryDivision_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_AddressCountryDivision_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_AddressCountryDivision] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_AddressCountryDivision_AddressCountry] FOREIGN KEY ([AddressCountryId]) REFERENCES [Static].[AddressCountry] ([Id]),
    INDEX [IX_AddressCountryDivision_AddressCountryId] NONCLUSTERED ([AddressCountryId])
);
GO

IF OBJECT_ID(N'[Static].[AddressState]', N'U') IS NULL
CREATE TABLE [Static].[AddressState]
(
    [Id]                       bigint        NOT NULL,
    [AddressCountryDivisionId] bigint        NOT NULL,
    [Name]                     nvarchar(100) NOT NULL,
    [Code]                     nvarchar(10)  NOT NULL,
    [CreatedBy]                bigint        NULL,
    [CreatedDateTime]          datetime2(7)  NOT NULL CONSTRAINT [DF_AddressState_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]               bigint        NULL,
    [ModifiedDateTime]         datetime2(7)  NOT NULL CONSTRAINT [DF_AddressState_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]                bigint        NULL,
    [DeletedDateTime]          datetime2(7)  NULL,
    [IsDeleted]                bit           NOT NULL CONSTRAINT [DF_AddressState_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_AddressState] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_AddressState_AddressCountryDivision] FOREIGN KEY ([AddressCountryDivisionId]) REFERENCES [Static].[AddressCountryDivision] ([Id]),
    INDEX [IX_AddressState_AddressCountryDivisionId] NONCLUSTERED ([AddressCountryDivisionId])
);
GO

IF OBJECT_ID(N'[Static].[AddressCity]', N'U') IS NULL
CREATE TABLE [Static].[AddressCity]
(
    [Id]               bigint        NOT NULL,
    [AddressStateId]   bigint        NOT NULL,
    [Name]             nvarchar(100) NOT NULL,
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_AddressCity_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_AddressCity_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_AddressCity_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_AddressCity] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_AddressCity_AddressState] FOREIGN KEY ([AddressStateId]) REFERENCES [Static].[AddressState] ([Id]),
    INDEX [IX_AddressCity_AddressStateId] NONCLUSTERED ([AddressStateId])
);
GO

IF OBJECT_ID(N'[Static].[AddressTown]', N'U') IS NULL
CREATE TABLE [Static].[AddressTown]
(
    [Id]               bigint        NOT NULL,
    [AddressCityId]    bigint        NOT NULL,
    [Name]             nvarchar(100) NOT NULL,
    [Code]             nvarchar(10)  NOT NULL,
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_AddressTown_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_AddressTown_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_AddressTown_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_AddressTown] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_AddressTown_AddressCity] FOREIGN KEY ([AddressCityId]) REFERENCES [Static].[AddressCity] ([Id]),
    INDEX [IX_AddressTown_AddressCityId] NONCLUSTERED ([AddressCityId])
);
GO

IF OBJECT_ID(N'[Static].[AttachmentType]', N'U') IS NULL
CREATE TABLE [Static].[AttachmentType]
(
    [Id]               bigint        NOT NULL,
    [Name]             nvarchar(100) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_AttachmentType_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_AttachmentType_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_AttachmentType_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_AttachmentType] PRIMARY KEY CLUSTERED ([Id])
);
GO

IF OBJECT_ID(N'[Static].[ClaimsStatus]', N'U') IS NULL
CREATE TABLE [Static].[ClaimsStatus]
(
    [Id]               bigint        NOT NULL,
    [Name]             nvarchar(100) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_ClaimsStatus_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_ClaimsStatus_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_ClaimsStatus_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_ClaimsStatus] PRIMARY KEY CLUSTERED ([Id])
);
GO

IF OBJECT_ID(N'[Static].[CocStatus]', N'U') IS NULL
CREATE TABLE [Static].[CocStatus]
(
    [Id]               bigint        NOT NULL,
    [Name]             nvarchar(100) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_CocStatus_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_CocStatus_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_CocStatus_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_CocStatus] PRIMARY KEY CLUSTERED ([Id])
);
GO

IF OBJECT_ID(N'[Static].[PaymentStatus]', N'U') IS NULL
CREATE TABLE [Static].[PaymentStatus]
(
    [Id]               bigint        NOT NULL,
    [Name]             nvarchar(100) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_PaymentStatus_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_PaymentStatus_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_PaymentStatus_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_PaymentStatus] PRIMARY KEY CLUSTERED ([Id])
);
GO

IF OBJECT_ID(N'[Static].[Platforms]', N'U') IS NULL
CREATE TABLE [Static].[Platforms]
(
    [Id]               bigint        NOT NULL,
    [Name]             nvarchar(100) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [Code]             nvarchar(10)  NOT NULL,
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_Platforms_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_Platforms_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_Platforms_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_Platforms] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_Platforms_Code] UNIQUE ([Code])
);
GO

IF OBJECT_ID(N'[Static].[PolicyBookingStatus]', N'U') IS NULL
CREATE TABLE [Static].[PolicyBookingStatus]
(
    [Id]               bigint        NOT NULL,
    [Name]             nvarchar(100) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_PolicyBookingStatus_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_PolicyBookingStatus_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_PolicyBookingStatus_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_PolicyBookingStatus] PRIMARY KEY CLUSTERED ([Id])
);
GO

IF OBJECT_ID(N'[Static].[PolicyType]', N'U') IS NULL
CREATE TABLE [Static].[PolicyType]
(
    [Id]               bigint        NOT NULL,
    [Name]             nvarchar(100) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_PolicyType_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_PolicyType_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_PolicyType_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_PolicyType] PRIMARY KEY CLUSTERED ([Id])
);
GO

IF OBJECT_ID(N'[Static].[SelectionType]', N'U') IS NULL
CREATE TABLE [Static].[SelectionType]
(
    [Id]               bigint        NOT NULL,
    [Name]             nvarchar(100) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_SelectionType_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_SelectionType_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_SelectionType_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_SelectionType] PRIMARY KEY CLUSTERED ([Id])
);
GO

/* =====================================================================
   Reference: maintained master data
   ===================================================================== */

IF OBJECT_ID(N'[Reference].[SelectionList]', N'U') IS NULL
CREATE TABLE [Reference].[SelectionList]
(
    [Id]               bigint        NOT NULL IDENTITY(1, 1),
    [SelectionTypeId]  bigint        NOT NULL,
    [Name]             nvarchar(150) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [IsActive]         bit           NOT NULL CONSTRAINT [DF_SelectionList_IsActive] DEFAULT (1),
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_SelectionList_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_SelectionList_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_SelectionList_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_SelectionList] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_SelectionList_SelectionType] FOREIGN KEY ([SelectionTypeId]) REFERENCES [Static].[SelectionType] ([Id]),
    CONSTRAINT [UQ_SelectionList_SelectionTypeId_Name] UNIQUE ([SelectionTypeId], [Name])
);
GO

IF OBJECT_ID(N'[Reference].[DistributionChannel]', N'U') IS NULL
CREATE TABLE [Reference].[DistributionChannel]
(
    [Id]               bigint        NOT NULL IDENTITY(1, 1),
    [Name]             nvarchar(150) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [Code]             nvarchar(30)  NOT NULL,
    [IsActive]         bit           NOT NULL CONSTRAINT [DF_DistributionChannel_IsActive] DEFAULT (1),
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_DistributionChannel_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_DistributionChannel_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_DistributionChannel_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_DistributionChannel] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_DistributionChannel_Code] UNIQUE ([Code])
);
GO

IF OBJECT_ID(N'[Reference].[ProductCategory]', N'U') IS NULL
CREATE TABLE [Reference].[ProductCategory]
(
    [Id]               bigint        NOT NULL IDENTITY(1, 1),
    [Name]             nvarchar(150) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [Code]             nvarchar(30)  NOT NULL,
    [IsActive]         bit           NOT NULL CONSTRAINT [DF_ProductCategory_IsActive] DEFAULT (1),
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_ProductCategory_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_ProductCategory_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_ProductCategory_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_ProductCategory] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_ProductCategory_Code] UNIQUE ([Code])
);
GO

IF OBJECT_ID(N'[Reference].[Products]', N'U') IS NULL
CREATE TABLE [Reference].[Products]
(
    [Id]                        bigint        NOT NULL IDENTITY(1, 1),
    [ProductCategoryId]         bigint        NOT NULL,
    [Name]                      nvarchar(150) NOT NULL,
    [Description]               nvarchar(500) NULL,
    [Code]                      nvarchar(30)  NOT NULL,
    [MinimumAge]                int           NULL,
    [MaximumAge]                int           NULL,
    [MaximumBookingPerYear]     int           NULL,
    [MaximumBookingPerDuration] int           NULL,
    [IsActive]                  bit           NOT NULL CONSTRAINT [DF_Products_IsActive] DEFAULT (1),
    [CreatedBy]                 bigint        NULL,
    [CreatedDateTime]           datetime2(7)  NOT NULL CONSTRAINT [DF_Products_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]                bigint        NULL,
    [ModifiedDateTime]          datetime2(7)  NOT NULL CONSTRAINT [DF_Products_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]                 bigint        NULL,
    [DeletedDateTime]           datetime2(7)  NULL,
    [IsDeleted]                 bit           NOT NULL CONSTRAINT [DF_Products_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_Products_ProductCategory] FOREIGN KEY ([ProductCategoryId]) REFERENCES [Reference].[ProductCategory] ([Id]),
    CONSTRAINT [UQ_Products_Code] UNIQUE ([Code]),
    CONSTRAINT [CK_Products_AgeRange] CHECK ([MinimumAge] IS NULL OR [MaximumAge] IS NULL OR [MinimumAge] <= [MaximumAge]),
    INDEX [IX_Products_ProductCategoryId] NONCLUSTERED ([ProductCategoryId])
);
GO

IF OBJECT_ID(N'[Reference].[ProductPremium]', N'U') IS NULL
CREATE TABLE [Reference].[ProductPremium]
(
    [Id]                     bigint        NOT NULL IDENTITY(1, 1),
    [ProductsId]             bigint        NOT NULL,
    [BasicPremium]           decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductPremium_BasicPremium] DEFAULT (0),
    [BasicPremiumCommission] decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductPremium_BasicPremiumCommission] DEFAULT (0),
    [DJDPatricioMarkup]      decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductPremium_DJDPatricioMarkup] DEFAULT (0),
    [PartnerMarkup]          decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductPremium_PartnerMarkup] DEFAULT (0),
    [Discount]               decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductPremium_Discount] DEFAULT (0),
    [Taxes]                  decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductPremium_Taxes] DEFAULT (0),
    [DST]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductPremium_DST] DEFAULT (0),
    [VAT]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductPremium_VAT] DEFAULT (0),
    [LGT]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductPremium_LGT] DEFAULT (0),
    [PT]                     decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductPremium_PT] DEFAULT (0),
    [FST]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductPremium_FST] DEFAULT (0),
    [NotarialFee]            decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductPremium_NotarialFee] DEFAULT (0),
    [Others]                 decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductPremium_Others] DEFAULT (0),
    [IsActive]               bit           NOT NULL CONSTRAINT [DF_ProductPremium_IsActive] DEFAULT (1),
    [CreatedBy]              bigint        NULL,
    [CreatedDateTime]        datetime2(7)  NOT NULL CONSTRAINT [DF_ProductPremium_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]             bigint        NULL,
    [ModifiedDateTime]       datetime2(7)  NOT NULL CONSTRAINT [DF_ProductPremium_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]              bigint        NULL,
    [DeletedDateTime]        datetime2(7)  NULL,
    [IsDeleted]              bit           NOT NULL CONSTRAINT [DF_ProductPremium_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_ProductPremium] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_ProductPremium_Products] FOREIGN KEY ([ProductsId]) REFERENCES [Reference].[Products] ([Id]),
    CONSTRAINT [UQ_ProductPremium_ProductsId] UNIQUE ([ProductsId])
);
GO

IF OBJECT_ID(N'[Reference].[Benefits]', N'U') IS NULL
CREATE TABLE [Reference].[Benefits]
(
    [Id]               bigint        NOT NULL IDENTITY(1, 1),
    [Name]             nvarchar(150) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [Code]             nvarchar(30)  NOT NULL,
    [IsActive]         bit           NOT NULL CONSTRAINT [DF_Benefits_IsActive] DEFAULT (1),
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_Benefits_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_Benefits_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_Benefits_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_Benefits] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_Benefits_Code] UNIQUE ([Code])
);
GO

IF OBJECT_ID(N'[Reference].[Deductibles]', N'U') IS NULL
CREATE TABLE [Reference].[Deductibles]
(
    [Id]               bigint        NOT NULL IDENTITY(1, 1),
    [Name]             nvarchar(150) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [Code]             nvarchar(30)  NOT NULL,
    [IsActive]         bit           NOT NULL CONSTRAINT [DF_Deductibles_IsActive] DEFAULT (1),
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_Deductibles_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_Deductibles_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_Deductibles_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_Deductibles] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_Deductibles_Code] UNIQUE ([Code])
);
GO

IF OBJECT_ID(N'[Reference].[ProductBenefits]', N'U') IS NULL
CREATE TABLE [Reference].[ProductBenefits]
(
    [Id]                      bigint         NOT NULL IDENTITY(1, 1),
    [ProductsId]              bigint         NOT NULL,
    [BenefitsId]              bigint         NOT NULL,
    [CoverageAmount]          decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductBenefits_CoverageAmount] DEFAULT (0),
    [PremiumAmount]           decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductBenefits_PremiumAmount] DEFAULT (0),
    [PremiumCommissionAmount] decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductBenefits_PremiumCommissionAmount] DEFAULT (0),
    [IsActive]                bit            NOT NULL CONSTRAINT [DF_ProductBenefits_IsActive] DEFAULT (1),
    [CreatedBy]               bigint         NULL,
    [CreatedDateTime]         datetime2(7)   NOT NULL CONSTRAINT [DF_ProductBenefits_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]              bigint         NULL,
    [ModifiedDateTime]        datetime2(7)   NOT NULL CONSTRAINT [DF_ProductBenefits_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]               bigint         NULL,
    [DeletedDateTime]         datetime2(7)   NULL,
    [IsDeleted]               bit            NOT NULL CONSTRAINT [DF_ProductBenefits_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_ProductBenefits] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_ProductBenefits_Products] FOREIGN KEY ([ProductsId]) REFERENCES [Reference].[Products] ([Id]),
    CONSTRAINT [FK_ProductBenefits_Benefits] FOREIGN KEY ([BenefitsId]) REFERENCES [Reference].[Benefits] ([Id]),
    CONSTRAINT [UQ_ProductBenefits_ProductsId_BenefitsId] UNIQUE ([ProductsId], [BenefitsId]),
    INDEX [IX_ProductBenefits_BenefitsId] NONCLUSTERED ([BenefitsId])
);
GO

IF OBJECT_ID(N'[Reference].[ProductDeductibles]', N'U') IS NULL
CREATE TABLE [Reference].[ProductDeductibles]
(
    [Id]               bigint         NOT NULL IDENTITY(1, 1),
    [ProductsId]       bigint         NOT NULL,
    [DeductiblesId]    bigint         NOT NULL,
    [Amount]           decimal(18, 2) NOT NULL CONSTRAINT [DF_ProductDeductibles_Amount] DEFAULT (0),
    [IsActive]         bit            NOT NULL CONSTRAINT [DF_ProductDeductibles_IsActive] DEFAULT (1),
    [CreatedBy]        bigint         NULL,
    [CreatedDateTime]  datetime2(7)   NOT NULL CONSTRAINT [DF_ProductDeductibles_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint         NULL,
    [ModifiedDateTime] datetime2(7)   NOT NULL CONSTRAINT [DF_ProductDeductibles_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint         NULL,
    [DeletedDateTime]  datetime2(7)   NULL,
    [IsDeleted]        bit            NOT NULL CONSTRAINT [DF_ProductDeductibles_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_ProductDeductibles] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_ProductDeductibles_Products] FOREIGN KEY ([ProductsId]) REFERENCES [Reference].[Products] ([Id]),
    CONSTRAINT [FK_ProductDeductibles_Deductibles] FOREIGN KEY ([DeductiblesId]) REFERENCES [Reference].[Deductibles] ([Id]),
    CONSTRAINT [UQ_ProductDeductibles_ProductsId_DeductiblesId] UNIQUE ([ProductsId], [DeductiblesId]),
    INDEX [IX_ProductDeductibles_DeductiblesId] NONCLUSTERED ([DeductiblesId])
);
GO

IF OBJECT_ID(N'[Reference].[Partners]', N'U') IS NULL
CREATE TABLE [Reference].[Partners]
(
    [Id]               bigint        NOT NULL IDENTITY(1, 1),
    [Name]             nvarchar(150) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [Code]             nvarchar(30)  NOT NULL,
    [ContactPerson]    nvarchar(150) NOT NULL,
    [EmailAddress]     nvarchar(100) NOT NULL,
    [ContactNumber]    nvarchar(13)  NOT NULL,
    [Address1]         nvarchar(150) NOT NULL,
    [Address2]         nvarchar(150) NULL,
    [AddressTownId]    bigint        NOT NULL,
    [IsActive]         bit           NOT NULL CONSTRAINT [DF_Partners_IsActive] DEFAULT (1),
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_Partners_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_Partners_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_Partners_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_Partners] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_Partners_AddressTown] FOREIGN KEY ([AddressTownId]) REFERENCES [Static].[AddressTown] ([Id]),
    CONSTRAINT [UQ_Partners_Code] UNIQUE ([Code]),
    INDEX [IX_Partners_AddressTownId] NONCLUSTERED ([AddressTownId])
);
GO

IF OBJECT_ID(N'[Reference].[Providers]', N'U') IS NULL
CREATE TABLE [Reference].[Providers]
(
    [Id]               bigint        NOT NULL IDENTITY(1, 1),
    [Name]             nvarchar(150) NOT NULL,
    [Description]      nvarchar(500) NULL,
    [Code]             nvarchar(30)  NOT NULL,
    [ContactPerson]    nvarchar(150) NOT NULL,
    [EmailAddress]     nvarchar(100) NOT NULL,
    [ContactNumber]    nvarchar(13)  NOT NULL,
    [Address1]         nvarchar(150) NOT NULL,
    [Address2]         nvarchar(150) NULL,
    [AddressTownId]    bigint        NOT NULL,
    [IsActive]         bit           NOT NULL CONSTRAINT [DF_Providers_IsActive] DEFAULT (1),
    [CreatedBy]        bigint        NULL,
    [CreatedDateTime]  datetime2(7)  NOT NULL CONSTRAINT [DF_Providers_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]       bigint        NULL,
    [ModifiedDateTime] datetime2(7)  NOT NULL CONSTRAINT [DF_Providers_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]        bigint        NULL,
    [DeletedDateTime]  datetime2(7)  NULL,
    [IsDeleted]        bit           NOT NULL CONSTRAINT [DF_Providers_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_Providers] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_Providers_AddressTown] FOREIGN KEY ([AddressTownId]) REFERENCES [Static].[AddressTown] ([Id]),
    CONSTRAINT [UQ_Providers_Code] UNIQUE ([Code]),
    INDEX [IX_Providers_AddressTownId] NONCLUSTERED ([AddressTownId])
);
GO

IF OBJECT_ID(N'[Reference].[Agents]', N'U') IS NULL
CREATE TABLE [Reference].[Agents]
(
    [Id]                   bigint        NOT NULL IDENTITY(1, 1),
    [DJDPatricioOrAgentId] nvarchar(20)  NOT NULL,
    [FirstName]            nvarchar(60)  NOT NULL,
    [MiddleName]           nvarchar(60)  NULL,
    [LastName]             nvarchar(60)  NOT NULL,
    [Suffix]               nvarchar(10)  NULL,
    [EmailAddress]         nvarchar(100) NOT NULL,
    [ContactNumber]        nvarchar(13)  NOT NULL,
    [DateOfBirth]          date          NOT NULL,
    [Address1]             nvarchar(150) NOT NULL,
    [Address2]             nvarchar(150) NULL,
    [AddressTownId]        bigint        NOT NULL,
    [IsActive]             bit           NOT NULL CONSTRAINT [DF_Agents_IsActive] DEFAULT (1),
    [CreatedBy]            bigint        NULL,
    [CreatedDateTime]      datetime2(7)  NOT NULL CONSTRAINT [DF_Agents_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]           bigint        NULL,
    [ModifiedDateTime]     datetime2(7)  NOT NULL CONSTRAINT [DF_Agents_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]            bigint        NULL,
    [DeletedDateTime]      datetime2(7)  NULL,
    [IsDeleted]            bit           NOT NULL CONSTRAINT [DF_Agents_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_Agents] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_Agents_AddressTown] FOREIGN KEY ([AddressTownId]) REFERENCES [Static].[AddressTown] ([Id]),
    CONSTRAINT [UQ_Agents_DJDPatricioOrAgentId] UNIQUE ([DJDPatricioOrAgentId]),
    INDEX [IX_Agents_AddressTownId] NONCLUSTERED ([AddressTownId])
);
GO

IF OBJECT_ID(N'[Reference].[Approvers]', N'U') IS NULL
CREATE TABLE [Reference].[Approvers]
(
    [Id]                   bigint        NOT NULL IDENTITY(1, 1),
    [DJDPatricioOrAgentId] nvarchar(20)  NOT NULL,
    [FirstName]            nvarchar(60)  NOT NULL,
    [MiddleName]           nvarchar(60)  NULL,
    [LastName]             nvarchar(60)  NOT NULL,
    [Suffix]               nvarchar(10)  NULL,
    [EmailAddress]         nvarchar(100) NOT NULL,
    [ContactNumber]        nvarchar(13)  NOT NULL,
    [DateOfBirth]          date          NOT NULL,
    [Address1]             nvarchar(150) NOT NULL,
    [Address2]             nvarchar(150) NULL,
    [AddressTownId]        bigint        NOT NULL,
    [IsActive]             bit           NOT NULL CONSTRAINT [DF_Approvers_IsActive] DEFAULT (1),
    [CreatedBy]            bigint        NULL,
    [CreatedDateTime]      datetime2(7)  NOT NULL CONSTRAINT [DF_Approvers_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]           bigint        NULL,
    [ModifiedDateTime]     datetime2(7)  NOT NULL CONSTRAINT [DF_Approvers_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]            bigint        NULL,
    [DeletedDateTime]      datetime2(7)  NULL,
    [IsDeleted]            bit           NOT NULL CONSTRAINT [DF_Approvers_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_Approvers] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_Approvers_AddressTown] FOREIGN KEY ([AddressTownId]) REFERENCES [Static].[AddressTown] ([Id]),
    CONSTRAINT [UQ_Approvers_DJDPatricioOrAgentId] UNIQUE ([DJDPatricioOrAgentId]),
    INDEX [IX_Approvers_AddressTownId] NONCLUSTERED ([AddressTownId])
);
GO

IF OBJECT_ID(N'[Reference].[SubAgents]', N'U') IS NULL
CREATE TABLE [Reference].[SubAgents]
(
    [Id]                   bigint        NOT NULL IDENTITY(1, 1),
    [DJDPatricioOrAgentId] nvarchar(20)  NOT NULL,
    [FirstName]            nvarchar(60)  NOT NULL,
    [MiddleName]           nvarchar(60)  NULL,
    [LastName]             nvarchar(60)  NOT NULL,
    [Suffix]               nvarchar(10)  NULL,
    [EmailAddress]         nvarchar(100) NOT NULL,
    [ContactNumber]        nvarchar(13)  NOT NULL,
    [DateOfBirth]          date          NOT NULL,
    [Address1]             nvarchar(150) NOT NULL,
    [Address2]             nvarchar(150) NULL,
    [AddressTownId]        bigint        NOT NULL,
    [IsActive]             bit           NOT NULL CONSTRAINT [DF_SubAgents_IsActive] DEFAULT (1),
    [CreatedBy]            bigint        NULL,
    [CreatedDateTime]      datetime2(7)  NOT NULL CONSTRAINT [DF_SubAgents_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]           bigint        NULL,
    [ModifiedDateTime]     datetime2(7)  NOT NULL CONSTRAINT [DF_SubAgents_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]            bigint        NULL,
    [DeletedDateTime]      datetime2(7)  NULL,
    [IsDeleted]            bit           NOT NULL CONSTRAINT [DF_SubAgents_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_SubAgents] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_SubAgents_AddressTown] FOREIGN KEY ([AddressTownId]) REFERENCES [Static].[AddressTown] ([Id]),
    CONSTRAINT [UQ_SubAgents_DJDPatricioOrAgentId] UNIQUE ([DJDPatricioOrAgentId]),
    INDEX [IX_SubAgents_AddressTownId] NONCLUSTERED ([AddressTownId])
);
GO

IF OBJECT_ID(N'[Reference].[PromoManagers]', N'U') IS NULL
CREATE TABLE [Reference].[PromoManagers]
(
    [Id]                   bigint        NOT NULL IDENTITY(1, 1),
    [AgentsId]             bigint        NOT NULL,
    [DJDPatricioOrAgentId] nvarchar(20)  NOT NULL,
    [FirstName]            nvarchar(60)  NOT NULL,
    [MiddleName]           nvarchar(60)  NULL,
    [LastName]             nvarchar(60)  NOT NULL,
    [Suffix]               nvarchar(10)  NULL,
    [EmailAddress]         nvarchar(100) NOT NULL,
    [ContactNumber]        nvarchar(13)  NOT NULL,
    [DateOfBirth]          date          NOT NULL,
    [Address1]             nvarchar(150) NOT NULL,
    [Address2]             nvarchar(150) NULL,
    [AddressTownId]        bigint        NOT NULL,
    [IsActive]             bit           NOT NULL CONSTRAINT [DF_PromoManagers_IsActive] DEFAULT (1),
    [CreatedBy]            bigint        NULL,
    [CreatedDateTime]      datetime2(7)  NOT NULL CONSTRAINT [DF_PromoManagers_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]           bigint        NULL,
    [ModifiedDateTime]     datetime2(7)  NOT NULL CONSTRAINT [DF_PromoManagers_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]            bigint        NULL,
    [DeletedDateTime]      datetime2(7)  NULL,
    [IsDeleted]            bit           NOT NULL CONSTRAINT [DF_PromoManagers_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_PromoManagers] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_PromoManagers_Agents] FOREIGN KEY ([AgentsId]) REFERENCES [Reference].[Agents] ([Id]),
    CONSTRAINT [FK_PromoManagers_AddressTown] FOREIGN KEY ([AddressTownId]) REFERENCES [Static].[AddressTown] ([Id]),
    CONSTRAINT [UQ_PromoManagers_DJDPatricioOrAgentId] UNIQUE ([DJDPatricioOrAgentId]),
    INDEX [IX_PromoManagers_AgentsId] NONCLUSTERED ([AgentsId]),
    INDEX [IX_PromoManagers_AddressTownId] NONCLUSTERED ([AddressTownId])
);
GO

IF OBJECT_ID(N'[Reference].[PromoOfficers]', N'U') IS NULL
CREATE TABLE [Reference].[PromoOfficers]
(
    [Id]                   bigint        NOT NULL IDENTITY(1, 1),
    [AgentsId]             bigint        NOT NULL,
    [DJDPatricioOrAgentId] nvarchar(20)  NOT NULL,
    [FirstName]            nvarchar(60)  NOT NULL,
    [MiddleName]           nvarchar(60)  NULL,
    [LastName]             nvarchar(60)  NOT NULL,
    [Suffix]               nvarchar(10)  NULL,
    [EmailAddress]         nvarchar(100) NOT NULL,
    [ContactNumber]        nvarchar(13)  NOT NULL,
    [DateOfBirth]          date          NOT NULL,
    [Address1]             nvarchar(150) NOT NULL,
    [Address2]             nvarchar(150) NULL,
    [AddressTownId]        bigint        NOT NULL,
    [IsActive]             bit           NOT NULL CONSTRAINT [DF_PromoOfficers_IsActive] DEFAULT (1),
    [CreatedBy]            bigint        NULL,
    [CreatedDateTime]      datetime2(7)  NOT NULL CONSTRAINT [DF_PromoOfficers_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]           bigint        NULL,
    [ModifiedDateTime]     datetime2(7)  NOT NULL CONSTRAINT [DF_PromoOfficers_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]            bigint        NULL,
    [DeletedDateTime]      datetime2(7)  NULL,
    [IsDeleted]            bit           NOT NULL CONSTRAINT [DF_PromoOfficers_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_PromoOfficers] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_PromoOfficers_Agents] FOREIGN KEY ([AgentsId]) REFERENCES [Reference].[Agents] ([Id]),
    CONSTRAINT [FK_PromoOfficers_AddressTown] FOREIGN KEY ([AddressTownId]) REFERENCES [Static].[AddressTown] ([Id]),
    CONSTRAINT [UQ_PromoOfficers_DJDPatricioOrAgentId] UNIQUE ([DJDPatricioOrAgentId]),
    INDEX [IX_PromoOfficers_AgentsId] NONCLUSTERED ([AgentsId]),
    INDEX [IX_PromoOfficers_AddressTownId] NONCLUSTERED ([AddressTownId])
);
GO

IF OBJECT_ID(N'[Reference].[SalesManagers]', N'U') IS NULL
CREATE TABLE [Reference].[SalesManagers]
(
    [Id]                   bigint        NOT NULL IDENTITY(1, 1),
    [AgentsId]             bigint        NOT NULL,
    [DJDPatricioOrAgentId] nvarchar(20)  NOT NULL,
    [FirstName]            nvarchar(60)  NOT NULL,
    [MiddleName]           nvarchar(60)  NULL,
    [LastName]             nvarchar(60)  NOT NULL,
    [Suffix]               nvarchar(10)  NULL,
    [EmailAddress]         nvarchar(100) NOT NULL,
    [ContactNumber]        nvarchar(13)  NOT NULL,
    [DateOfBirth]          date          NOT NULL,
    [Address1]             nvarchar(150) NOT NULL,
    [Address2]             nvarchar(150) NULL,
    [AddressTownId]        bigint        NOT NULL,
    [IsActive]             bit           NOT NULL CONSTRAINT [DF_SalesManagers_IsActive] DEFAULT (1),
    [CreatedBy]            bigint        NULL,
    [CreatedDateTime]      datetime2(7)  NOT NULL CONSTRAINT [DF_SalesManagers_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]           bigint        NULL,
    [ModifiedDateTime]     datetime2(7)  NOT NULL CONSTRAINT [DF_SalesManagers_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]            bigint        NULL,
    [DeletedDateTime]      datetime2(7)  NULL,
    [IsDeleted]            bit           NOT NULL CONSTRAINT [DF_SalesManagers_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_SalesManagers] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_SalesManagers_Agents] FOREIGN KEY ([AgentsId]) REFERENCES [Reference].[Agents] ([Id]),
    CONSTRAINT [FK_SalesManagers_AddressTown] FOREIGN KEY ([AddressTownId]) REFERENCES [Static].[AddressTown] ([Id]),
    CONSTRAINT [UQ_SalesManagers_DJDPatricioOrAgentId] UNIQUE ([DJDPatricioOrAgentId]),
    INDEX [IX_SalesManagers_AgentsId] NONCLUSTERED ([AgentsId]),
    INDEX [IX_SalesManagers_AddressTownId] NONCLUSTERED ([AddressTownId])
);
GO

IF OBJECT_ID(N'[Reference].[Clients]', N'U') IS NULL
CREATE TABLE [Reference].[Clients]
(
    [Id]                     bigint        NOT NULL IDENTITY(1, 1),
    [InsuranceCustomerNo]    nvarchar(20)  NOT NULL,
    [FirstName]              nvarchar(60)  NOT NULL,
    [MiddleName]             nvarchar(60)  NULL,
    [LastName]               nvarchar(60)  NOT NULL,
    [Suffix]                 nvarchar(10)  NULL,
    [EmailAddress]           nvarchar(100) NOT NULL,
    [ContactNumber]          nvarchar(13)  NOT NULL,
    [DateOfBirth]            date          NOT NULL,
    [IsMale]                 bit           NOT NULL,
    [ValidIdPresented]       bigint        NOT NULL,
    [ValidIdPresentedNumber] nvarchar(50)  NOT NULL,
    [ValidIdExpiration]      date          NOT NULL,
    [Address1]               nvarchar(150) NOT NULL,
    [Address2]               nvarchar(150) NULL,
    [AddressTownId]          bigint        NOT NULL,
    [IsActive]               bit           NOT NULL CONSTRAINT [DF_Clients_IsActive] DEFAULT (1),
    [CreatedBy]              bigint        NULL,
    [CreatedDateTime]        datetime2(7)  NOT NULL CONSTRAINT [DF_Clients_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]             bigint        NULL,
    [ModifiedDateTime]       datetime2(7)  NOT NULL CONSTRAINT [DF_Clients_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]              bigint        NULL,
    [DeletedDateTime]        datetime2(7)  NULL,
    [IsDeleted]              bit           NOT NULL CONSTRAINT [DF_Clients_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_Clients] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_Clients_SelectionList_ValidIdPresented] FOREIGN KEY ([ValidIdPresented]) REFERENCES [Reference].[SelectionList] ([Id]),
    CONSTRAINT [FK_Clients_AddressTown] FOREIGN KEY ([AddressTownId]) REFERENCES [Static].[AddressTown] ([Id]),
    CONSTRAINT [UQ_Clients_InsuranceCustomerNo] UNIQUE ([InsuranceCustomerNo]),
    INDEX [IX_Clients_ValidIdPresented] NONCLUSTERED ([ValidIdPresented]),
    INDEX [IX_Clients_AddressTownId] NONCLUSTERED ([AddressTownId])
);
GO

/* =====================================================================
   Transaction: policy bookings and their child records
   Child tables point at a policy with (PolicyId, PolicyTypeId); persisted computed
   columns turn that pair into real foreign keys to each policy table.
   ===================================================================== */

IF OBJECT_ID(N'[Transaction].[IndividualPolicy]', N'U') IS NULL
CREATE TABLE [Transaction].[IndividualPolicy]
(
    [Id]                     bigint         NOT NULL IDENTITY(1, 1),
    [ReferenceNumber]        nvarchar(12)   NOT NULL,
    [CocNumber]              nvarchar(12)   NOT NULL,
    [ClientsId]              bigint         NOT NULL,
    [PartnersId]             bigint         NOT NULL,
    [PlatformsId]            bigint         NOT NULL,
    [IssueStatus]            bit            NOT NULL CONSTRAINT [DF_IndividualPolicy_IssueStatus] DEFAULT (1),
    [PolicyBookingStatusId]  bigint         NOT NULL,
    [CocStatusId]            bigint         NOT NULL,
    [PaymentStatusId]        bigint         NOT NULL,
    [ClaimsStatusId]         bigint         NOT NULL,
    [AgentsId]               bigint         NOT NULL,
    [SubAgentsId]            bigint         NULL,
    [ApproversId]            bigint         NOT NULL,
    [PromoManagersId]        bigint         NULL,
    [SalesManagersId]        bigint         NULL,
    [PromoOfficersId]        bigint         NULL,
    [ProductsId]             bigint         NOT NULL,
    [ProvidersId]            bigint         NOT NULL,
    [DistributionChannelId]  bigint         NOT NULL,
    [PaymentOptionId]        bigint         NOT NULL,
    [ProviderPolicyNo]       nvarchar(50)   NOT NULL,
    [EndorsementNo]          nvarchar(50)   NULL,
    [TerminationDate]        date           NOT NULL,
    [EffectiveDate]          date           NOT NULL,
    [IssueDate]              date           NOT NULL,
    [Remarks]                nvarchar(500)  NULL,
    [BasicPremium]           decimal(18, 2) NOT NULL CONSTRAINT [DF_IndividualPolicy_BasicPremium] DEFAULT (0),
    [BasicPremiumCommission] decimal(18, 2) NOT NULL CONSTRAINT [DF_IndividualPolicy_BasicPremiumCommission] DEFAULT (0),
    [DJDPatricioMarkup]      decimal(18, 2) NOT NULL CONSTRAINT [DF_IndividualPolicy_DJDPatricioMarkup] DEFAULT (0),
    [PartnerMarkup]          decimal(18, 2) NOT NULL CONSTRAINT [DF_IndividualPolicy_PartnerMarkup] DEFAULT (0),
    [Discount]               decimal(18, 2) NOT NULL CONSTRAINT [DF_IndividualPolicy_Discount] DEFAULT (0),
    [Taxes]                  decimal(18, 2) NOT NULL CONSTRAINT [DF_IndividualPolicy_Taxes] DEFAULT (0),
    [DST]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_IndividualPolicy_DST] DEFAULT (0),
    [VAT]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_IndividualPolicy_VAT] DEFAULT (0),
    [LGT]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_IndividualPolicy_LGT] DEFAULT (0),
    [PT]                     decimal(18, 2) NOT NULL CONSTRAINT [DF_IndividualPolicy_PT] DEFAULT (0),
    [FST]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_IndividualPolicy_FST] DEFAULT (0),
    [NotarialFee]            decimal(18, 2) NOT NULL CONSTRAINT [DF_IndividualPolicy_NotarialFee] DEFAULT (0),
    [Others]                 decimal(18, 2) NOT NULL CONSTRAINT [DF_IndividualPolicy_Others] DEFAULT (0),
    [PremiumsRemarks]        nvarchar(500)  NULL,
    [CreatedBy]              bigint         NULL,
    [CreatedDateTime]        datetime2(7)   NOT NULL CONSTRAINT [DF_IndividualPolicy_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]             bigint         NULL,
    [ModifiedDateTime]       datetime2(7)   NOT NULL CONSTRAINT [DF_IndividualPolicy_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]              bigint         NULL,
    [DeletedDateTime]        datetime2(7)   NULL,
    [IsDeleted]              bit            NOT NULL CONSTRAINT [DF_IndividualPolicy_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_IndividualPolicy] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_IndividualPolicy_ReferenceNumber] UNIQUE ([ReferenceNumber]),
    CONSTRAINT [UQ_IndividualPolicy_CocNumber] UNIQUE ([CocNumber]),
    CONSTRAINT [CK_IndividualPolicy_Dates] CHECK ([EffectiveDate] <= [TerminationDate]),
    CONSTRAINT [FK_IndividualPolicy_Clients] FOREIGN KEY ([ClientsId]) REFERENCES [Reference].[Clients] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_Partners] FOREIGN KEY ([PartnersId]) REFERENCES [Reference].[Partners] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_Platforms] FOREIGN KEY ([PlatformsId]) REFERENCES [Static].[Platforms] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_PolicyBookingStatus] FOREIGN KEY ([PolicyBookingStatusId]) REFERENCES [Static].[PolicyBookingStatus] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_CocStatus] FOREIGN KEY ([CocStatusId]) REFERENCES [Static].[CocStatus] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_PaymentStatus] FOREIGN KEY ([PaymentStatusId]) REFERENCES [Static].[PaymentStatus] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_ClaimsStatus] FOREIGN KEY ([ClaimsStatusId]) REFERENCES [Static].[ClaimsStatus] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_Agents] FOREIGN KEY ([AgentsId]) REFERENCES [Reference].[Agents] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_SubAgents] FOREIGN KEY ([SubAgentsId]) REFERENCES [Reference].[SubAgents] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_Approvers] FOREIGN KEY ([ApproversId]) REFERENCES [Reference].[Approvers] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_PromoManagers] FOREIGN KEY ([PromoManagersId]) REFERENCES [Reference].[PromoManagers] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_SalesManagers] FOREIGN KEY ([SalesManagersId]) REFERENCES [Reference].[SalesManagers] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_PromoOfficers] FOREIGN KEY ([PromoOfficersId]) REFERENCES [Reference].[PromoOfficers] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_Products] FOREIGN KEY ([ProductsId]) REFERENCES [Reference].[Products] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_Providers] FOREIGN KEY ([ProvidersId]) REFERENCES [Reference].[Providers] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_DistributionChannel] FOREIGN KEY ([DistributionChannelId]) REFERENCES [Reference].[DistributionChannel] ([Id]),
    CONSTRAINT [FK_IndividualPolicy_SelectionList_PaymentOption] FOREIGN KEY ([PaymentOptionId]) REFERENCES [Reference].[SelectionList] ([Id]),
    INDEX [IX_IndividualPolicy_ClientsId] NONCLUSTERED ([ClientsId]),
    INDEX [IX_IndividualPolicy_PartnersId] NONCLUSTERED ([PartnersId]),
    INDEX [IX_IndividualPolicy_ProductsId] NONCLUSTERED ([ProductsId]),
    INDEX [IX_IndividualPolicy_AgentsId] NONCLUSTERED ([AgentsId]),
    INDEX [IX_IndividualPolicy_PolicyBookingStatusId] NONCLUSTERED ([PolicyBookingStatusId]),
    INDEX [IX_IndividualPolicy_CreatedDateTime] NONCLUSTERED ([CreatedDateTime]) INCLUDE ([PolicyBookingStatusId], [ProductsId], [IsDeleted])
);
GO

IF OBJECT_ID(N'[Transaction].[PartnerPolicy]', N'U') IS NULL
CREATE TABLE [Transaction].[PartnerPolicy]
(
    [Id]                     bigint         NOT NULL IDENTITY(1, 1),
    [ReferenceNumber]        nvarchar(12)   NOT NULL,
    [CocNumber]              nvarchar(12)   NOT NULL,
    [PartnersId]             bigint         NOT NULL,
    [PlatformsId]            bigint         NOT NULL,
    [IssueStatus]            bit            NOT NULL CONSTRAINT [DF_PartnerPolicy_IssueStatus] DEFAULT (1),
    [PolicyBookingStatusId]  bigint         NOT NULL,
    [CocStatusId]            bigint         NOT NULL,
    [PaymentStatusId]        bigint         NOT NULL,
    [ClaimsStatusId]         bigint         NOT NULL,
    [AgentsId]               bigint         NOT NULL,
    [SubAgentsId]            bigint         NULL,
    [ApproversId]            bigint         NOT NULL,
    [PromoManagersId]        bigint         NULL,
    [SalesManagersId]        bigint         NULL,
    [PromoOfficersId]        bigint         NULL,
    [ProductsId]             bigint         NOT NULL,
    [ProvidersId]            bigint         NOT NULL,
    [DistributionChannelId]  bigint         NOT NULL,
    [PaymentOptionId]        bigint         NOT NULL,
    [ProviderPolicyNo]       nvarchar(50)   NOT NULL,
    [EndorsementNo]          nvarchar(50)   NULL,
    [TerminationDate]        date           NOT NULL,
    [EffectiveDate]          date           NOT NULL,
    [IssueDate]              date           NOT NULL,
    [Remarks]                nvarchar(500)  NULL,
    [BasicPremium]           decimal(18, 2) NOT NULL CONSTRAINT [DF_PartnerPolicy_BasicPremium] DEFAULT (0),
    [BasicPremiumCommission] decimal(18, 2) NOT NULL CONSTRAINT [DF_PartnerPolicy_BasicPremiumCommission] DEFAULT (0),
    [DJDPatricioMarkup]      decimal(18, 2) NOT NULL CONSTRAINT [DF_PartnerPolicy_DJDPatricioMarkup] DEFAULT (0),
    [PartnerMarkup]          decimal(18, 2) NOT NULL CONSTRAINT [DF_PartnerPolicy_PartnerMarkup] DEFAULT (0),
    [Discount]               decimal(18, 2) NOT NULL CONSTRAINT [DF_PartnerPolicy_Discount] DEFAULT (0),
    [Taxes]                  decimal(18, 2) NOT NULL CONSTRAINT [DF_PartnerPolicy_Taxes] DEFAULT (0),
    [DST]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_PartnerPolicy_DST] DEFAULT (0),
    [VAT]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_PartnerPolicy_VAT] DEFAULT (0),
    [LGT]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_PartnerPolicy_LGT] DEFAULT (0),
    [PT]                     decimal(18, 2) NOT NULL CONSTRAINT [DF_PartnerPolicy_PT] DEFAULT (0),
    [FST]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_PartnerPolicy_FST] DEFAULT (0),
    [NotarialFee]            decimal(18, 2) NOT NULL CONSTRAINT [DF_PartnerPolicy_NotarialFee] DEFAULT (0),
    [Others]                 decimal(18, 2) NOT NULL CONSTRAINT [DF_PartnerPolicy_Others] DEFAULT (0),
    [PremiumsRemarks]        nvarchar(500)  NULL,
    [CreatedBy]              bigint         NULL,
    [CreatedDateTime]        datetime2(7)   NOT NULL CONSTRAINT [DF_PartnerPolicy_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]             bigint         NULL,
    [ModifiedDateTime]       datetime2(7)   NOT NULL CONSTRAINT [DF_PartnerPolicy_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]              bigint         NULL,
    [DeletedDateTime]        datetime2(7)   NULL,
    [IsDeleted]              bit            NOT NULL CONSTRAINT [DF_PartnerPolicy_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_PartnerPolicy] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_PartnerPolicy_ReferenceNumber] UNIQUE ([ReferenceNumber]),
    CONSTRAINT [UQ_PartnerPolicy_CocNumber] UNIQUE ([CocNumber]),
    CONSTRAINT [CK_PartnerPolicy_Dates] CHECK ([EffectiveDate] <= [TerminationDate]),
    CONSTRAINT [FK_PartnerPolicy_Partners] FOREIGN KEY ([PartnersId]) REFERENCES [Reference].[Partners] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_Platforms] FOREIGN KEY ([PlatformsId]) REFERENCES [Static].[Platforms] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_PolicyBookingStatus] FOREIGN KEY ([PolicyBookingStatusId]) REFERENCES [Static].[PolicyBookingStatus] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_CocStatus] FOREIGN KEY ([CocStatusId]) REFERENCES [Static].[CocStatus] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_PaymentStatus] FOREIGN KEY ([PaymentStatusId]) REFERENCES [Static].[PaymentStatus] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_ClaimsStatus] FOREIGN KEY ([ClaimsStatusId]) REFERENCES [Static].[ClaimsStatus] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_Agents] FOREIGN KEY ([AgentsId]) REFERENCES [Reference].[Agents] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_SubAgents] FOREIGN KEY ([SubAgentsId]) REFERENCES [Reference].[SubAgents] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_Approvers] FOREIGN KEY ([ApproversId]) REFERENCES [Reference].[Approvers] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_PromoManagers] FOREIGN KEY ([PromoManagersId]) REFERENCES [Reference].[PromoManagers] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_SalesManagers] FOREIGN KEY ([SalesManagersId]) REFERENCES [Reference].[SalesManagers] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_PromoOfficers] FOREIGN KEY ([PromoOfficersId]) REFERENCES [Reference].[PromoOfficers] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_Products] FOREIGN KEY ([ProductsId]) REFERENCES [Reference].[Products] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_Providers] FOREIGN KEY ([ProvidersId]) REFERENCES [Reference].[Providers] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_DistributionChannel] FOREIGN KEY ([DistributionChannelId]) REFERENCES [Reference].[DistributionChannel] ([Id]),
    CONSTRAINT [FK_PartnerPolicy_SelectionList_PaymentOption] FOREIGN KEY ([PaymentOptionId]) REFERENCES [Reference].[SelectionList] ([Id]),
    INDEX [IX_PartnerPolicy_PartnersId] NONCLUSTERED ([PartnersId]),
    INDEX [IX_PartnerPolicy_ProductsId] NONCLUSTERED ([ProductsId]),
    INDEX [IX_PartnerPolicy_AgentsId] NONCLUSTERED ([AgentsId]),
    INDEX [IX_PartnerPolicy_PolicyBookingStatusId] NONCLUSTERED ([PolicyBookingStatusId]),
    INDEX [IX_PartnerPolicy_CreatedDateTime] NONCLUSTERED ([CreatedDateTime]) INCLUDE ([PolicyBookingStatusId], [ProductsId], [IsDeleted])
);
GO

IF OBJECT_ID(N'[Transaction].[GroupPolicy]', N'U') IS NULL
CREATE TABLE [Transaction].[GroupPolicy]
(
    [Id]                     bigint         NOT NULL IDENTITY(1, 1),
    [ReferenceNumber]        nvarchar(12)   NOT NULL,
    [CocNumber]              nvarchar(12)   NOT NULL,
    [PartnersId]             bigint         NOT NULL,
    [PlatformsId]            bigint         NOT NULL,
    [IssueStatus]            bit            NOT NULL CONSTRAINT [DF_GroupPolicy_IssueStatus] DEFAULT (1),
    [PolicyBookingStatusId]  bigint         NOT NULL,
    [CocStatusId]            bigint         NOT NULL,
    [PaymentStatusId]        bigint         NOT NULL,
    [ClaimsStatusId]         bigint         NOT NULL,
    [AgentsId]               bigint         NOT NULL,
    [SubAgentsId]            bigint         NULL,
    [ApproversId]            bigint         NOT NULL,
    [PromoManagersId]        bigint         NULL,
    [SalesManagersId]        bigint         NULL,
    [PromoOfficersId]        bigint         NULL,
    [ProductsId]             bigint         NOT NULL,
    [ProvidersId]            bigint         NOT NULL,
    [DistributionChannelId]  bigint         NOT NULL,
    [PaymentOptionId]        bigint         NOT NULL,
    [AccountTypeId]          bigint         NOT NULL,
    [BranchCode]             nvarchar(5)    NULL,
    [BranchName]             nvarchar(6)    NULL,
    [ProviderPolicyNo]       nvarchar(50)   NOT NULL,
    [EndorsementNo]          nvarchar(50)   NULL,
    [TerminationDate]        date           NOT NULL,
    [EffectiveDate]          date           NOT NULL,
    [IssueDate]              date           NOT NULL,
    [Remarks]                nvarchar(500)  NULL,
    [BasicPremium]           decimal(18, 2) NOT NULL CONSTRAINT [DF_GroupPolicy_BasicPremium] DEFAULT (0),
    [BasicPremiumCommission] decimal(18, 2) NOT NULL CONSTRAINT [DF_GroupPolicy_BasicPremiumCommission] DEFAULT (0),
    [DJDPatricioMarkup]      decimal(18, 2) NOT NULL CONSTRAINT [DF_GroupPolicy_DJDPatricioMarkup] DEFAULT (0),
    [PartnerMarkup]          decimal(18, 2) NOT NULL CONSTRAINT [DF_GroupPolicy_PartnerMarkup] DEFAULT (0),
    [Discount]               decimal(18, 2) NOT NULL CONSTRAINT [DF_GroupPolicy_Discount] DEFAULT (0),
    [Taxes]                  decimal(18, 2) NOT NULL CONSTRAINT [DF_GroupPolicy_Taxes] DEFAULT (0),
    [DST]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_GroupPolicy_DST] DEFAULT (0),
    [VAT]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_GroupPolicy_VAT] DEFAULT (0),
    [LGT]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_GroupPolicy_LGT] DEFAULT (0),
    [PT]                     decimal(18, 2) NOT NULL CONSTRAINT [DF_GroupPolicy_PT] DEFAULT (0),
    [FST]                    decimal(18, 2) NOT NULL CONSTRAINT [DF_GroupPolicy_FST] DEFAULT (0),
    [NotarialFee]            decimal(18, 2) NOT NULL CONSTRAINT [DF_GroupPolicy_NotarialFee] DEFAULT (0),
    [Others]                 decimal(18, 2) NOT NULL CONSTRAINT [DF_GroupPolicy_Others] DEFAULT (0),
    [PremiumsRemarks]        nvarchar(500)  NULL,
    [CreatedBy]              bigint         NULL,
    [CreatedDateTime]        datetime2(7)   NOT NULL CONSTRAINT [DF_GroupPolicy_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]             bigint         NULL,
    [ModifiedDateTime]       datetime2(7)   NOT NULL CONSTRAINT [DF_GroupPolicy_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]              bigint         NULL,
    [DeletedDateTime]        datetime2(7)   NULL,
    [IsDeleted]              bit            NOT NULL CONSTRAINT [DF_GroupPolicy_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_GroupPolicy] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [UQ_GroupPolicy_ReferenceNumber] UNIQUE ([ReferenceNumber]),
    CONSTRAINT [UQ_GroupPolicy_CocNumber] UNIQUE ([CocNumber]),
    CONSTRAINT [CK_GroupPolicy_Dates] CHECK ([EffectiveDate] <= [TerminationDate]),
    CONSTRAINT [FK_GroupPolicy_Partners] FOREIGN KEY ([PartnersId]) REFERENCES [Reference].[Partners] ([Id]),
    CONSTRAINT [FK_GroupPolicy_Platforms] FOREIGN KEY ([PlatformsId]) REFERENCES [Static].[Platforms] ([Id]),
    CONSTRAINT [FK_GroupPolicy_PolicyBookingStatus] FOREIGN KEY ([PolicyBookingStatusId]) REFERENCES [Static].[PolicyBookingStatus] ([Id]),
    CONSTRAINT [FK_GroupPolicy_CocStatus] FOREIGN KEY ([CocStatusId]) REFERENCES [Static].[CocStatus] ([Id]),
    CONSTRAINT [FK_GroupPolicy_PaymentStatus] FOREIGN KEY ([PaymentStatusId]) REFERENCES [Static].[PaymentStatus] ([Id]),
    CONSTRAINT [FK_GroupPolicy_ClaimsStatus] FOREIGN KEY ([ClaimsStatusId]) REFERENCES [Static].[ClaimsStatus] ([Id]),
    CONSTRAINT [FK_GroupPolicy_Agents] FOREIGN KEY ([AgentsId]) REFERENCES [Reference].[Agents] ([Id]),
    CONSTRAINT [FK_GroupPolicy_SubAgents] FOREIGN KEY ([SubAgentsId]) REFERENCES [Reference].[SubAgents] ([Id]),
    CONSTRAINT [FK_GroupPolicy_Approvers] FOREIGN KEY ([ApproversId]) REFERENCES [Reference].[Approvers] ([Id]),
    CONSTRAINT [FK_GroupPolicy_PromoManagers] FOREIGN KEY ([PromoManagersId]) REFERENCES [Reference].[PromoManagers] ([Id]),
    CONSTRAINT [FK_GroupPolicy_SalesManagers] FOREIGN KEY ([SalesManagersId]) REFERENCES [Reference].[SalesManagers] ([Id]),
    CONSTRAINT [FK_GroupPolicy_PromoOfficers] FOREIGN KEY ([PromoOfficersId]) REFERENCES [Reference].[PromoOfficers] ([Id]),
    CONSTRAINT [FK_GroupPolicy_Products] FOREIGN KEY ([ProductsId]) REFERENCES [Reference].[Products] ([Id]),
    CONSTRAINT [FK_GroupPolicy_Providers] FOREIGN KEY ([ProvidersId]) REFERENCES [Reference].[Providers] ([Id]),
    CONSTRAINT [FK_GroupPolicy_DistributionChannel] FOREIGN KEY ([DistributionChannelId]) REFERENCES [Reference].[DistributionChannel] ([Id]),
    CONSTRAINT [FK_GroupPolicy_SelectionList_PaymentOption] FOREIGN KEY ([PaymentOptionId]) REFERENCES [Reference].[SelectionList] ([Id]),
    CONSTRAINT [FK_GroupPolicy_SelectionList_AccountType] FOREIGN KEY ([AccountTypeId]) REFERENCES [Reference].[SelectionList] ([Id]),
    INDEX [IX_GroupPolicy_PartnersId] NONCLUSTERED ([PartnersId]),
    INDEX [IX_GroupPolicy_ProductsId] NONCLUSTERED ([ProductsId]),
    INDEX [IX_GroupPolicy_AgentsId] NONCLUSTERED ([AgentsId]),
    INDEX [IX_GroupPolicy_PolicyBookingStatusId] NONCLUSTERED ([PolicyBookingStatusId]),
    INDEX [IX_GroupPolicy_CreatedDateTime] NONCLUSTERED ([CreatedDateTime]) INCLUDE ([PolicyBookingStatusId], [ProductsId], [IsDeleted])
);
GO

IF OBJECT_ID(N'[Transaction].[PolicyBeneficiary]', N'U') IS NULL
CREATE TABLE [Transaction].[PolicyBeneficiary]
(
    [Id]                 bigint        NOT NULL IDENTITY(1, 1),
    [PolicyId]           bigint        NOT NULL,
    [PolicyTypeId]       bigint        NOT NULL,
    [FirstName]          nvarchar(60)  NOT NULL,
    [MiddleName]         nvarchar(60)  NULL,
    [LastName]           nvarchar(60)  NOT NULL,
    [Suffix]             nvarchar(10)  NULL,
    [EmailAddress]       nvarchar(100) NOT NULL,
    [ContactNumber]      nvarchar(13)  NOT NULL,
    [DateOfBirth]        date          NOT NULL,
    [Relationship]       bigint        NOT NULL,
    [IndividualPolicyId] AS (CASE WHEN [PolicyTypeId] = 1 THEN [PolicyId] END) PERSISTED,
    [PartnerPolicyId]    AS (CASE WHEN [PolicyTypeId] = 2 THEN [PolicyId] END) PERSISTED,
    [GroupPolicyId]      AS (CASE WHEN [PolicyTypeId] = 3 THEN [PolicyId] END) PERSISTED,
    [CreatedBy]          bigint        NULL,
    [CreatedDateTime]    datetime2(7)  NOT NULL CONSTRAINT [DF_PolicyBeneficiary_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]         bigint        NULL,
    [ModifiedDateTime]   datetime2(7)  NOT NULL CONSTRAINT [DF_PolicyBeneficiary_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]          bigint        NULL,
    [DeletedDateTime]    datetime2(7)  NULL,
    [IsDeleted]          bit           NOT NULL CONSTRAINT [DF_PolicyBeneficiary_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_PolicyBeneficiary] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_PolicyBeneficiary_PolicyType] FOREIGN KEY ([PolicyTypeId]) REFERENCES [Static].[PolicyType] ([Id]),
    CONSTRAINT [FK_PolicyBeneficiary_IndividualPolicy] FOREIGN KEY ([IndividualPolicyId]) REFERENCES [Transaction].[IndividualPolicy] ([Id]),
    CONSTRAINT [FK_PolicyBeneficiary_PartnerPolicy] FOREIGN KEY ([PartnerPolicyId]) REFERENCES [Transaction].[PartnerPolicy] ([Id]),
    CONSTRAINT [FK_PolicyBeneficiary_GroupPolicy] FOREIGN KEY ([GroupPolicyId]) REFERENCES [Transaction].[GroupPolicy] ([Id]),
    CONSTRAINT [FK_PolicyBeneficiary_SelectionList_Relationship] FOREIGN KEY ([Relationship]) REFERENCES [Reference].[SelectionList] ([Id]),
    INDEX [IX_PolicyBeneficiary_PolicyTypeId_PolicyId] NONCLUSTERED ([PolicyTypeId], [PolicyId]),
    INDEX [IX_PolicyBeneficiary_Relationship] NONCLUSTERED ([Relationship])
);
GO

IF OBJECT_ID(N'[Transaction].[PolicyBenefits]', N'U') IS NULL
CREATE TABLE [Transaction].[PolicyBenefits]
(
    [Id]                      bigint         NOT NULL IDENTITY(1, 1),
    [PolicyId]                bigint         NOT NULL,
    [PolicyTypeId]            bigint         NOT NULL,
    [BenefitsId]              bigint         NOT NULL,
    [CoverageAmount]          decimal(18, 2) NOT NULL CONSTRAINT [DF_PolicyBenefits_CoverageAmount] DEFAULT (0),
    [PremiumAmount]           decimal(18, 2) NOT NULL CONSTRAINT [DF_PolicyBenefits_PremiumAmount] DEFAULT (0),
    [PremiumCommissionAmount] decimal(18, 2) NOT NULL CONSTRAINT [DF_PolicyBenefits_PremiumCommissionAmount] DEFAULT (0),
    [IndividualPolicyId]      AS (CASE WHEN [PolicyTypeId] = 1 THEN [PolicyId] END) PERSISTED,
    [PartnerPolicyId]         AS (CASE WHEN [PolicyTypeId] = 2 THEN [PolicyId] END) PERSISTED,
    [GroupPolicyId]           AS (CASE WHEN [PolicyTypeId] = 3 THEN [PolicyId] END) PERSISTED,
    [CreatedBy]               bigint         NULL,
    [CreatedDateTime]         datetime2(7)   NOT NULL CONSTRAINT [DF_PolicyBenefits_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]              bigint         NULL,
    [ModifiedDateTime]        datetime2(7)   NOT NULL CONSTRAINT [DF_PolicyBenefits_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]               bigint         NULL,
    [DeletedDateTime]         datetime2(7)   NULL,
    [IsDeleted]               bit            NOT NULL CONSTRAINT [DF_PolicyBenefits_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_PolicyBenefits] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_PolicyBenefits_PolicyType] FOREIGN KEY ([PolicyTypeId]) REFERENCES [Static].[PolicyType] ([Id]),
    CONSTRAINT [FK_PolicyBenefits_IndividualPolicy] FOREIGN KEY ([IndividualPolicyId]) REFERENCES [Transaction].[IndividualPolicy] ([Id]),
    CONSTRAINT [FK_PolicyBenefits_PartnerPolicy] FOREIGN KEY ([PartnerPolicyId]) REFERENCES [Transaction].[PartnerPolicy] ([Id]),
    CONSTRAINT [FK_PolicyBenefits_GroupPolicy] FOREIGN KEY ([GroupPolicyId]) REFERENCES [Transaction].[GroupPolicy] ([Id]),
    CONSTRAINT [FK_PolicyBenefits_Benefits] FOREIGN KEY ([BenefitsId]) REFERENCES [Reference].[Benefits] ([Id]),
    INDEX [IX_PolicyBenefits_PolicyTypeId_PolicyId] NONCLUSTERED ([PolicyTypeId], [PolicyId]) INCLUDE ([CoverageAmount], [PremiumAmount], [IsDeleted]),
    INDEX [IX_PolicyBenefits_BenefitsId] NONCLUSTERED ([BenefitsId])
);
GO

IF OBJECT_ID(N'[Transaction].[PolicyDeductibles]', N'U') IS NULL
CREATE TABLE [Transaction].[PolicyDeductibles]
(
    [Id]                 bigint         NOT NULL IDENTITY(1, 1),
    [PolicyId]           bigint         NOT NULL,
    [PolicyTypeId]       bigint         NOT NULL,
    [DeductiblesId]      bigint         NOT NULL,
    [Amount]             decimal(18, 2) NOT NULL CONSTRAINT [DF_PolicyDeductibles_Amount] DEFAULT (0),
    [IndividualPolicyId] AS (CASE WHEN [PolicyTypeId] = 1 THEN [PolicyId] END) PERSISTED,
    [PartnerPolicyId]    AS (CASE WHEN [PolicyTypeId] = 2 THEN [PolicyId] END) PERSISTED,
    [GroupPolicyId]      AS (CASE WHEN [PolicyTypeId] = 3 THEN [PolicyId] END) PERSISTED,
    [CreatedBy]          bigint         NULL,
    [CreatedDateTime]    datetime2(7)   NOT NULL CONSTRAINT [DF_PolicyDeductibles_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]         bigint         NULL,
    [ModifiedDateTime]   datetime2(7)   NOT NULL CONSTRAINT [DF_PolicyDeductibles_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]          bigint         NULL,
    [DeletedDateTime]    datetime2(7)   NULL,
    [IsDeleted]          bit            NOT NULL CONSTRAINT [DF_PolicyDeductibles_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_PolicyDeductibles] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_PolicyDeductibles_PolicyType] FOREIGN KEY ([PolicyTypeId]) REFERENCES [Static].[PolicyType] ([Id]),
    CONSTRAINT [FK_PolicyDeductibles_IndividualPolicy] FOREIGN KEY ([IndividualPolicyId]) REFERENCES [Transaction].[IndividualPolicy] ([Id]),
    CONSTRAINT [FK_PolicyDeductibles_PartnerPolicy] FOREIGN KEY ([PartnerPolicyId]) REFERENCES [Transaction].[PartnerPolicy] ([Id]),
    CONSTRAINT [FK_PolicyDeductibles_GroupPolicy] FOREIGN KEY ([GroupPolicyId]) REFERENCES [Transaction].[GroupPolicy] ([Id]),
    CONSTRAINT [FK_PolicyDeductibles_Deductibles] FOREIGN KEY ([DeductiblesId]) REFERENCES [Reference].[Deductibles] ([Id]),
    INDEX [IX_PolicyDeductibles_PolicyTypeId_PolicyId] NONCLUSTERED ([PolicyTypeId], [PolicyId]),
    INDEX [IX_PolicyDeductibles_DeductiblesId] NONCLUSTERED ([DeductiblesId])
);
GO

IF OBJECT_ID(N'[Transaction].[PolicyPayments]', N'U') IS NULL
CREATE TABLE [Transaction].[PolicyPayments]
(
    [Id]                   bigint         NOT NULL IDENTITY(1, 1),
    [PolicyId]             bigint         NOT NULL,
    [PolicyTypeId]         bigint         NOT NULL,
    [Amount]               decimal(18, 2) NOT NULL,
    [TransactionDateTime]  datetime2(7)   NOT NULL,
    [TransactionCheckNo]   nvarchar(50)   NOT NULL,
    [TransactionOrigin]    nvarchar(50)   NOT NULL,
    [NotificationDateTime] datetime2(7)   NOT NULL,
    [PaymentMethod]        bigint         NOT NULL,
    [Notes]                nvarchar(500)  NULL,
    [IndividualPolicyId]   AS (CASE WHEN [PolicyTypeId] = 1 THEN [PolicyId] END) PERSISTED,
    [PartnerPolicyId]      AS (CASE WHEN [PolicyTypeId] = 2 THEN [PolicyId] END) PERSISTED,
    [GroupPolicyId]        AS (CASE WHEN [PolicyTypeId] = 3 THEN [PolicyId] END) PERSISTED,
    [CreatedBy]            bigint         NULL,
    [CreatedDateTime]      datetime2(7)   NOT NULL CONSTRAINT [DF_PolicyPayments_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]           bigint         NULL,
    [ModifiedDateTime]     datetime2(7)   NOT NULL CONSTRAINT [DF_PolicyPayments_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]            bigint         NULL,
    [DeletedDateTime]      datetime2(7)   NULL,
    [IsDeleted]            bit            NOT NULL CONSTRAINT [DF_PolicyPayments_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_PolicyPayments] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_PolicyPayments_PolicyType] FOREIGN KEY ([PolicyTypeId]) REFERENCES [Static].[PolicyType] ([Id]),
    CONSTRAINT [FK_PolicyPayments_IndividualPolicy] FOREIGN KEY ([IndividualPolicyId]) REFERENCES [Transaction].[IndividualPolicy] ([Id]),
    CONSTRAINT [FK_PolicyPayments_PartnerPolicy] FOREIGN KEY ([PartnerPolicyId]) REFERENCES [Transaction].[PartnerPolicy] ([Id]),
    CONSTRAINT [FK_PolicyPayments_GroupPolicy] FOREIGN KEY ([GroupPolicyId]) REFERENCES [Transaction].[GroupPolicy] ([Id]),
    CONSTRAINT [FK_PolicyPayments_SelectionList_PaymentMethod] FOREIGN KEY ([PaymentMethod]) REFERENCES [Reference].[SelectionList] ([Id]),
    INDEX [IX_PolicyPayments_PolicyTypeId_PolicyId] NONCLUSTERED ([PolicyTypeId], [PolicyId]) INCLUDE ([Amount], [IsDeleted]),
    INDEX [IX_PolicyPayments_PaymentMethod] NONCLUSTERED ([PaymentMethod]),
    INDEX [IX_PolicyPayments_TransactionDateTime] NONCLUSTERED ([TransactionDateTime]) INCLUDE ([Amount], [IsDeleted])
);
GO

IF OBJECT_ID(N'[Transaction].[Attachments]', N'U') IS NULL
CREATE TABLE [Transaction].[Attachments]
(
    [Id]                 bigint         NOT NULL IDENTITY(1, 1),
    [ReferenceId]        bigint         NOT NULL,
    [AttachmentTypeId]   bigint         NOT NULL,
    [ContentType]        nvarchar(100)  NULL,
    [FileName]           nvarchar(255)  NOT NULL,
    [Attachment]         varbinary(max) NOT NULL,
    [IndividualPolicyId] AS (CASE WHEN [AttachmentTypeId] = 1 THEN [ReferenceId] END) PERSISTED,
    [PartnerPolicyId]    AS (CASE WHEN [AttachmentTypeId] = 2 THEN [ReferenceId] END) PERSISTED,
    [GroupPolicyId]      AS (CASE WHEN [AttachmentTypeId] IN (3, 4) THEN [ReferenceId] END) PERSISTED,
    [PolicyPaymentsId]   AS (CASE WHEN [AttachmentTypeId] = 5 THEN [ReferenceId] END) PERSISTED,
    [CreatedBy]          bigint         NULL,
    [CreatedDateTime]    datetime2(7)   NOT NULL CONSTRAINT [DF_Attachments_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
    [ModifiedBy]         bigint         NULL,
    [ModifiedDateTime]   datetime2(7)   NOT NULL CONSTRAINT [DF_Attachments_ModifiedDateTime] DEFAULT (SYSUTCDATETIME()),
    [DeletedBy]          bigint         NULL,
    [DeletedDateTime]    datetime2(7)   NULL,
    [IsDeleted]          bit            NOT NULL CONSTRAINT [DF_Attachments_IsDeleted] DEFAULT (0),
    CONSTRAINT [PK_Attachments] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_Attachments_AttachmentType] FOREIGN KEY ([AttachmentTypeId]) REFERENCES [Static].[AttachmentType] ([Id]),
    CONSTRAINT [FK_Attachments_IndividualPolicy] FOREIGN KEY ([IndividualPolicyId]) REFERENCES [Transaction].[IndividualPolicy] ([Id]),
    CONSTRAINT [FK_Attachments_PartnerPolicy] FOREIGN KEY ([PartnerPolicyId]) REFERENCES [Transaction].[PartnerPolicy] ([Id]),
    CONSTRAINT [FK_Attachments_GroupPolicy] FOREIGN KEY ([GroupPolicyId]) REFERENCES [Transaction].[GroupPolicy] ([Id]),
    CONSTRAINT [FK_Attachments_PolicyPayments] FOREIGN KEY ([PolicyPaymentsId]) REFERENCES [Transaction].[PolicyPayments] ([Id]),
    INDEX [IX_Attachments_AttachmentTypeId_ReferenceId] NONCLUSTERED ([AttachmentTypeId], [ReferenceId])
);
GO

/* Sequences behind the generated policy reference numbers (IPB/PPB/GPB + 9 digits) and the shared COC number (12 digits). */
IF OBJECT_ID(N'[Transaction].[IndividualPolicyNumberSequence]', N'SO') IS NULL
    CREATE SEQUENCE [Transaction].[IndividualPolicyNumberSequence] AS bigint START WITH 1 INCREMENT BY 1 NO CYCLE;
IF OBJECT_ID(N'[Transaction].[PartnerPolicyNumberSequence]', N'SO') IS NULL
    CREATE SEQUENCE [Transaction].[PartnerPolicyNumberSequence] AS bigint START WITH 1 INCREMENT BY 1 NO CYCLE;
IF OBJECT_ID(N'[Transaction].[GroupPolicyNumberSequence]', N'SO') IS NULL
    CREATE SEQUENCE [Transaction].[GroupPolicyNumberSequence] AS bigint START WITH 1 INCREMENT BY 1 NO CYCLE;
IF OBJECT_ID(N'[Transaction].[CocNumberSequence]', N'SO') IS NULL
    CREATE SEQUENCE [Transaction].[CocNumberSequence] AS bigint START WITH 1 INCREMENT BY 1 NO CYCLE;
GO

/* =====================================================================
   Functions
   ===================================================================== */

/* "Juan M. Dela Cruz Jr.": first name, middle initial, last name, suffix. */
CREATE OR ALTER FUNCTION [dbo].[FormatFullName]
(
    @FirstName  nvarchar(60),
    @MiddleName nvarchar(60),
    @LastName   nvarchar(60),
    @Suffix     nvarchar(10)
)
RETURNS nvarchar(200)
WITH SCHEMABINDING
AS
BEGIN
    RETURN NULLIF(LTRIM(CONCAT(
        LTRIM(RTRIM(@FirstName)),
        N' ' + LEFT(NULLIF(LTRIM(RTRIM(@MiddleName)), N''), 1) + N'.',
        N' ' + LTRIM(RTRIM(@LastName)),
        N' ' + NULLIF(LTRIM(RTRIM(@Suffix)), N''))), N'');
END;
GO

/* "123 Mabini St., Macasipac, Santa Maria, Laguna, Region IV-A, Philippines": street lines plus the town hierarchy. */
CREATE OR ALTER FUNCTION [Static].[FormatAddress]
(
    @Address1      nvarchar(150),
    @Address2      nvarchar(150),
    @AddressTownId bigint
)
RETURNS nvarchar(800)
AS
BEGIN
    DECLARE @Locality nvarchar(600);

    SELECT @Locality = CONCAT(t.[Name], N', ', c.[Name], N', ', s.[Name], N', ', cd.[Acronym], N', ', co.[Name])
    FROM [Static].[AddressTown] AS t
    INNER JOIN [Static].[AddressCity] AS c ON c.[Id] = t.[AddressCityId]
    INNER JOIN [Static].[AddressState] AS s ON s.[Id] = c.[AddressStateId]
    INNER JOIN [Static].[AddressCountryDivision] AS cd ON cd.[Id] = s.[AddressCountryDivisionId]
    INNER JOIN [Static].[AddressCountry] AS co ON co.[Id] = cd.[AddressCountryId]
    WHERE t.[Id] = @AddressTownId;

    RETURN CONCAT(@Address1, N', ' + NULLIF(@Address2, N''), N', ' + @Locality);
END;
GO

/* Comma separated id list (as sent by the API for multi-value status filters) to a set of bigint ids. */
CREATE OR ALTER FUNCTION [dbo].[SplitIds]
(
    @List nvarchar(4000)
)
RETURNS TABLE
AS
RETURN
    SELECT DISTINCT TRY_CAST(LTRIM(RTRIM(s.[value])) AS bigint) AS [Id]
    FROM STRING_SPLIT(@List, N',') AS s
    WHERE TRY_CAST(LTRIM(RTRIM(s.[value])) AS bigint) IS NOT NULL;
GO

/* Row offset and fetch size for a page, mirroring GlobalFunctionsHelper.CreatePagedResponse:
   pageSize 0 returns everything, pageNumber 0 means the last page, pages past the end clamp to the last page. */
CREATE OR ALTER FUNCTION [dbo].[GetPagination]
(
    @PageNumber   int,
    @PageSize     int,
    @TotalRecords bigint
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT
        CASE WHEN p.[PageSize] = 0 THEN CAST(0 AS bigint) ELSE (p.[PageNumber] - 1) * p.[PageSize] END AS [RowOffset],
        CASE WHEN p.[PageSize] = 0 THEN CASE WHEN @TotalRecords > 0 THEN @TotalRecords ELSE CAST(1 AS bigint) END ELSE p.[PageSize] END AS [RowFetch]
    FROM
    (
        SELECT
            s.[PageSize],
            CASE
                WHEN s.[PageSize] = 0 THEN CAST(1 AS bigint)
                WHEN s.[PageNumber] = 0 THEN s.[TotalPages]
                WHEN s.[PageNumber] < 0 THEN CAST(1 AS bigint)
                WHEN @TotalRecords > 0 AND s.[PageNumber] > s.[TotalPages] THEN s.[TotalPages]
                ELSE s.[PageNumber]
            END AS [PageNumber]
        FROM
        (
            SELECT
                CAST(ISNULL(@PageNumber, 1) AS bigint) AS [PageNumber],
                CASE WHEN ISNULL(@PageSize, 0) > 0 THEN CAST(@PageSize AS bigint) ELSE CAST(0 AS bigint) END AS [PageSize],
                CASE
                    WHEN ISNULL(@PageSize, 0) > 0 AND @TotalRecords > 0 THEN (@TotalRecords + @PageSize - 1) / @PageSize
                    ELSE CAST(1 AS bigint)
                END AS [TotalPages]
        ) AS s
    ) AS p;
GO

/* Reporting buckets for StaticDataHelper.TimePeriodOption, oldest first:
   1 Year5 = 5 yearly buckets, 2 Year1 = 12 monthly buckets, 3 Month6 = 6 monthly buckets, 4 Day30 (default) = 30 daily buckets. */
CREATE OR ALTER FUNCTION [dbo].[GetActivityPeriods]
(
    @TimePeriodOption int,
    @AsOfDate         date
)
RETURNS TABLE
AS
RETURN
    WITH [Numbers] AS
    (
        SELECT TOP (30) CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS int) AS [N]
        FROM (VALUES (0), (0), (0), (0), (0), (0)) AS a ([X])
        CROSS JOIN (VALUES (0), (0), (0), (0), (0)) AS b ([X])
    ),
    [Options] AS
    (
        SELECT CASE WHEN @TimePeriodOption IN (1, 2, 3, 4) THEN @TimePeriodOption ELSE 4 END AS [TimePeriodOption]
    )
    SELECT
        b.[ActivityDate],
        CASE o.[TimePeriodOption]
            WHEN 1 THEN DATEADD(YEAR, 1, b.[ActivityDate])
            WHEN 4 THEN DATEADD(DAY, 1, b.[ActivityDate])
            ELSE DATEADD(MONTH, 1, b.[ActivityDate])
        END AS [PeriodEnd]
    FROM [Numbers] AS n
    CROSS JOIN [Options] AS o
    CROSS APPLY
    (
        SELECT CASE o.[TimePeriodOption]
            WHEN 1 THEN DATEFROMPARTS(YEAR(@AsOfDate) - n.[N], 1, 1)
            WHEN 4 THEN DATEADD(DAY, -n.[N], @AsOfDate)
            ELSE DATEADD(MONTH, -n.[N], DATEFROMPARTS(YEAR(@AsOfDate), MONTH(@AsOfDate), 1))
        END AS [ActivityDate]
    ) AS b
    WHERE n.[N] < CASE o.[TimePeriodOption] WHEN 1 THEN 5 WHEN 2 THEN 12 WHEN 3 THEN 6 ELSE 30 END;
GO

/* "IPB000000001", "PPB000000001", "GPB000000001". */
CREATE OR ALTER FUNCTION [Transaction].[FormatReferenceNumber]
(
    @PolicyTypeId   bigint,
    @SequenceNumber bigint
)
RETURNS nvarchar(12)
WITH SCHEMABINDING
AS
BEGIN
    RETURN CONCAT(
        CASE @PolicyTypeId WHEN 1 THEN N'IPB' WHEN 2 THEN N'PPB' WHEN 3 THEN N'GPB' END,
        RIGHT(REPLICATE(N'0', 9) + CAST(@SequenceNumber AS nvarchar(20)), 9));
END;
GO

/* "000000000001": certificate of coverage number shared by all policy types. */
CREATE OR ALTER FUNCTION [Transaction].[FormatCocNumber]
(
    @SequenceNumber bigint
)
RETURNS nvarchar(12)
WITH SCHEMABINDING
AS
BEGIN
    RETURN RIGHT(REPLICATE(N'0', 12) + CAST(@SequenceNumber AS nvarchar(20)), 12);
END;
GO

/* Payment status (StaticDataHelper.PaymentStatus) from what is due and what was paid. Cancelled (4) is only ever set by hand. */
CREATE OR ALTER FUNCTION [Transaction].[GetPaymentStatusId]
(
    @TotalPremium decimal(18, 2),
    @TotalPaid    decimal(18, 2)
)
RETURNS bigint
WITH SCHEMABINDING
AS
BEGIN
    RETURN CASE
        WHEN ISNULL(@TotalPaid, 0) <= 0 THEN 2
        WHEN @TotalPaid < ISNULL(@TotalPremium, 0) THEN 3
        WHEN @TotalPaid = ISNULL(@TotalPremium, 0) THEN 1
        ELSE 5
    END;
END;
GO

/* Totals of one policy. TotalPremium = benefit premiums + premium charges (basic premium, markups, taxes and fees, less discount;
   the agent commission is not charged to the client). TotalCoverage = benefit coverage. TotalPaid = payments. */
CREATE OR ALTER FUNCTION [Transaction].[GetPolicyTotals]
(
    @PolicyTypeId bigint,
    @PolicyId     bigint
)
RETURNS TABLE
AS
RETURN
    SELECT
        CAST(ISNULL(b.[BenefitsPremium], 0) + ISNULL(c.[PremiumCharges], 0) AS decimal(18, 2)) AS [TotalPremium],
        CAST(ISNULL(b.[TotalCoverage], 0) AS decimal(18, 2)) AS [TotalCoverage],
        CAST(ISNULL(pay.[TotalPaid], 0) AS decimal(18, 2)) AS [TotalPaid]
    FROM
    (
        SELECT SUM(pb.[PremiumAmount]) AS [BenefitsPremium], SUM(pb.[CoverageAmount]) AS [TotalCoverage]
        FROM [Transaction].[PolicyBenefits] AS pb
        WHERE pb.[PolicyTypeId] = @PolicyTypeId AND pb.[PolicyId] = @PolicyId AND pb.[IsDeleted] = 0
    ) AS b
    CROSS JOIN
    (
        SELECT SUM(pp.[Amount]) AS [TotalPaid]
        FROM [Transaction].[PolicyPayments] AS pp
        WHERE pp.[PolicyTypeId] = @PolicyTypeId AND pp.[PolicyId] = @PolicyId AND pp.[IsDeleted] = 0
    ) AS pay
    CROSS JOIN
    (
        SELECT SUM(x.[Charges]) AS [PremiumCharges]
        FROM
        (
            SELECT p.[BasicPremium] + p.[DJDPatricioMarkup] + p.[PartnerMarkup] + p.[Taxes] + p.[DST] + p.[VAT] + p.[LGT] + p.[PT] + p.[FST] + p.[NotarialFee] + p.[Others] - p.[Discount] AS [Charges]
            FROM [Transaction].[IndividualPolicy] AS p
            WHERE @PolicyTypeId = 1 AND p.[Id] = @PolicyId
            UNION ALL
            SELECT p.[BasicPremium] + p.[DJDPatricioMarkup] + p.[PartnerMarkup] + p.[Taxes] + p.[DST] + p.[VAT] + p.[LGT] + p.[PT] + p.[FST] + p.[NotarialFee] + p.[Others] - p.[Discount]
            FROM [Transaction].[PartnerPolicy] AS p
            WHERE @PolicyTypeId = 2 AND p.[Id] = @PolicyId
            UNION ALL
            SELECT p.[BasicPremium] + p.[DJDPatricioMarkup] + p.[PartnerMarkup] + p.[Taxes] + p.[DST] + p.[VAT] + p.[LGT] + p.[PT] + p.[FST] + p.[NotarialFee] + p.[Others] - p.[Discount]
            FROM [Transaction].[GroupPolicy] AS p
            WHERE @PolicyTypeId = 3 AND p.[Id] = @PolicyId
        ) AS x
    ) AS c;
GO

/* =====================================================================
   Views
   ===================================================================== */

/* Every policy of every type with its key fields and totals, for child views and dashboards. */
CREATE OR ALTER VIEW [Transaction].[PolicyView]
AS
    SELECT
        k.[PolicyTypeId], k.[PolicyId], k.[ReferenceNumber], k.[CocNumber], k.[ClientsId], k.[PartnersId], k.[ProductsId],
        k.[PolicyBookingStatusId], k.[PaymentStatusId], k.[CreatedDateTime], k.[IsDeleted],
        t.[TotalPremium], t.[TotalCoverage], t.[TotalPaid]
    FROM
    (
        SELECT CAST(1 AS bigint) AS [PolicyTypeId], p.[Id] AS [PolicyId], p.[ReferenceNumber], p.[CocNumber], p.[ClientsId], p.[PartnersId], p.[ProductsId],
               p.[PolicyBookingStatusId], p.[PaymentStatusId], p.[CreatedDateTime], p.[IsDeleted]
        FROM [Transaction].[IndividualPolicy] AS p
        UNION ALL
        SELECT CAST(2 AS bigint), p.[Id], p.[ReferenceNumber], p.[CocNumber], CAST(NULL AS bigint), p.[PartnersId], p.[ProductsId],
               p.[PolicyBookingStatusId], p.[PaymentStatusId], p.[CreatedDateTime], p.[IsDeleted]
        FROM [Transaction].[PartnerPolicy] AS p
        UNION ALL
        SELECT CAST(3 AS bigint), p.[Id], p.[ReferenceNumber], p.[CocNumber], CAST(NULL AS bigint), p.[PartnersId], p.[ProductsId],
               p.[PolicyBookingStatusId], p.[PaymentStatusId], p.[CreatedDateTime], p.[IsDeleted]
        FROM [Transaction].[GroupPolicy] AS p
    ) AS k
    CROSS APPLY [Transaction].[GetPolicyTotals](k.[PolicyTypeId], k.[PolicyId]) AS t;
GO

CREATE OR ALTER VIEW [Transaction].[IndividualPolicyView]
AS
    SELECT
        p.[Id], p.[ReferenceNumber], p.[CocNumber], p.[ClientsId], p.[PartnersId], p.[PlatformsId], p.[IssueStatus],
        p.[PolicyBookingStatusId], p.[CocStatusId], p.[PaymentStatusId], p.[ClaimsStatusId],
        p.[AgentsId], p.[SubAgentsId], p.[ApproversId], p.[PromoManagersId], p.[SalesManagersId], p.[PromoOfficersId],
        p.[ProductsId], p.[ProvidersId], p.[DistributionChannelId], p.[PaymentOptionId],
        p.[ProviderPolicyNo], p.[EndorsementNo], p.[TerminationDate], p.[EffectiveDate], p.[IssueDate], p.[Remarks],
        t.[TotalPremium], t.[TotalCoverage], t.[TotalPaid],
        p.[BasicPremium], p.[BasicPremiumCommission], p.[DJDPatricioMarkup], p.[PartnerMarkup], p.[Discount], p.[Taxes],
        p.[DST], p.[VAT], p.[LGT], p.[PT], p.[FST], p.[NotarialFee], p.[Others], p.[PremiumsRemarks],
        p.[CreatedBy], p.[CreatedDateTime], p.[ModifiedBy], p.[ModifiedDateTime],
        [dbo].[FormatFullName](cl.[FirstName], cl.[MiddleName], cl.[LastName], cl.[Suffix]) AS [Clients],
        cl.[InsuranceCustomerNo] AS [ClientsInsuranceCustomerNo],
        pa.[Name] AS [Partners],
        pl.[Name] AS [Platforms],
        CASE WHEN p.[IssueStatus] = 1 THEN N'Active' ELSE N'Inactive' END AS [IssueStatusTitle],
        pbs.[Name] AS [PolicyBookingStatus],
        cs.[Name] AS [CocStatus],
        ps.[Name] AS [PaymentStatus],
        cls.[Name] AS [ClaimsStatus],
        [dbo].[FormatFullName](ag.[FirstName], ag.[MiddleName], ag.[LastName], ag.[Suffix]) AS [Agents],
        [dbo].[FormatFullName](sa.[FirstName], sa.[MiddleName], sa.[LastName], sa.[Suffix]) AS [SubAgents],
        [dbo].[FormatFullName](ap.[FirstName], ap.[MiddleName], ap.[LastName], ap.[Suffix]) AS [Approvers],
        [dbo].[FormatFullName](pm.[FirstName], pm.[MiddleName], pm.[LastName], pm.[Suffix]) AS [PromoManagers],
        [dbo].[FormatFullName](sm.[FirstName], sm.[MiddleName], sm.[LastName], sm.[Suffix]) AS [SalesManagers],
        [dbo].[FormatFullName](po.[FirstName], po.[MiddleName], po.[LastName], po.[Suffix]) AS [PromoOfficers],
        ISNULL(pc.[Description], pc.[Name]) AS [ProductCategory],
        pr.[ProductCategoryId],
        pr.[Name] AS [Products],
        pv.[Name] AS [Providers],
        dc.[Name] AS [DistributionChannel],
        opt.[Name] AS [PaymentOption]
    FROM [Transaction].[IndividualPolicy] AS p
    CROSS APPLY [Transaction].[GetPolicyTotals](1, p.[Id]) AS t
    INNER JOIN [Reference].[Clients] AS cl ON cl.[Id] = p.[ClientsId]
    INNER JOIN [Reference].[Partners] AS pa ON pa.[Id] = p.[PartnersId]
    INNER JOIN [Static].[Platforms] AS pl ON pl.[Id] = p.[PlatformsId]
    INNER JOIN [Static].[PolicyBookingStatus] AS pbs ON pbs.[Id] = p.[PolicyBookingStatusId]
    INNER JOIN [Static].[CocStatus] AS cs ON cs.[Id] = p.[CocStatusId]
    INNER JOIN [Static].[PaymentStatus] AS ps ON ps.[Id] = p.[PaymentStatusId]
    INNER JOIN [Static].[ClaimsStatus] AS cls ON cls.[Id] = p.[ClaimsStatusId]
    INNER JOIN [Reference].[Agents] AS ag ON ag.[Id] = p.[AgentsId]
    LEFT JOIN [Reference].[SubAgents] AS sa ON sa.[Id] = p.[SubAgentsId]
    INNER JOIN [Reference].[Approvers] AS ap ON ap.[Id] = p.[ApproversId]
    LEFT JOIN [Reference].[PromoManagers] AS pm ON pm.[Id] = p.[PromoManagersId]
    LEFT JOIN [Reference].[SalesManagers] AS sm ON sm.[Id] = p.[SalesManagersId]
    LEFT JOIN [Reference].[PromoOfficers] AS po ON po.[Id] = p.[PromoOfficersId]
    INNER JOIN [Reference].[Products] AS pr ON pr.[Id] = p.[ProductsId]
    INNER JOIN [Reference].[ProductCategory] AS pc ON pc.[Id] = pr.[ProductCategoryId]
    INNER JOIN [Reference].[Providers] AS pv ON pv.[Id] = p.[ProvidersId]
    INNER JOIN [Reference].[DistributionChannel] AS dc ON dc.[Id] = p.[DistributionChannelId]
    INNER JOIN [Reference].[SelectionList] AS opt ON opt.[Id] = p.[PaymentOptionId]
    WHERE p.[IsDeleted] = 0;
GO

CREATE OR ALTER VIEW [Transaction].[PartnerPolicyView]
AS
    SELECT
        p.[Id], p.[ReferenceNumber], p.[CocNumber], p.[PartnersId], p.[PlatformsId], p.[IssueStatus],
        p.[PolicyBookingStatusId], p.[CocStatusId], p.[PaymentStatusId], p.[ClaimsStatusId],
        p.[AgentsId], p.[SubAgentsId], p.[ApproversId], p.[PromoManagersId], p.[SalesManagersId], p.[PromoOfficersId],
        p.[ProductsId], p.[ProvidersId], p.[DistributionChannelId], p.[PaymentOptionId],
        p.[ProviderPolicyNo], p.[EndorsementNo], p.[TerminationDate], p.[EffectiveDate], p.[IssueDate], p.[Remarks],
        t.[TotalPremium], t.[TotalCoverage], t.[TotalPaid],
        p.[BasicPremium], p.[BasicPremiumCommission], p.[DJDPatricioMarkup], p.[PartnerMarkup], p.[Discount], p.[Taxes],
        p.[DST], p.[VAT], p.[LGT], p.[PT], p.[FST], p.[NotarialFee], p.[Others], p.[PremiumsRemarks],
        p.[CreatedBy], p.[CreatedDateTime], p.[ModifiedBy], p.[ModifiedDateTime],
        pa.[Name] AS [Partners],
        pa.[Code] AS [PartnersCode],
        pl.[Name] AS [Platforms],
        CASE WHEN p.[IssueStatus] = 1 THEN N'Active' ELSE N'Inactive' END AS [IssueStatusTitle],
        pbs.[Name] AS [PolicyBookingStatus],
        cs.[Name] AS [CocStatus],
        ps.[Name] AS [PaymentStatus],
        cls.[Name] AS [ClaimsStatus],
        [dbo].[FormatFullName](ag.[FirstName], ag.[MiddleName], ag.[LastName], ag.[Suffix]) AS [Agents],
        [dbo].[FormatFullName](sa.[FirstName], sa.[MiddleName], sa.[LastName], sa.[Suffix]) AS [SubAgents],
        [dbo].[FormatFullName](ap.[FirstName], ap.[MiddleName], ap.[LastName], ap.[Suffix]) AS [Approvers],
        [dbo].[FormatFullName](pm.[FirstName], pm.[MiddleName], pm.[LastName], pm.[Suffix]) AS [PromoManagers],
        [dbo].[FormatFullName](sm.[FirstName], sm.[MiddleName], sm.[LastName], sm.[Suffix]) AS [SalesManagers],
        [dbo].[FormatFullName](po.[FirstName], po.[MiddleName], po.[LastName], po.[Suffix]) AS [PromoOfficers],
        ISNULL(pc.[Description], pc.[Name]) AS [ProductCategory],
        pr.[ProductCategoryId],
        pr.[Name] AS [Products],
        pv.[Name] AS [Providers],
        dc.[Name] AS [DistributionChannel],
        opt.[Name] AS [PaymentOption]
    FROM [Transaction].[PartnerPolicy] AS p
    CROSS APPLY [Transaction].[GetPolicyTotals](2, p.[Id]) AS t
    INNER JOIN [Reference].[Partners] AS pa ON pa.[Id] = p.[PartnersId]
    INNER JOIN [Static].[Platforms] AS pl ON pl.[Id] = p.[PlatformsId]
    INNER JOIN [Static].[PolicyBookingStatus] AS pbs ON pbs.[Id] = p.[PolicyBookingStatusId]
    INNER JOIN [Static].[CocStatus] AS cs ON cs.[Id] = p.[CocStatusId]
    INNER JOIN [Static].[PaymentStatus] AS ps ON ps.[Id] = p.[PaymentStatusId]
    INNER JOIN [Static].[ClaimsStatus] AS cls ON cls.[Id] = p.[ClaimsStatusId]
    INNER JOIN [Reference].[Agents] AS ag ON ag.[Id] = p.[AgentsId]
    LEFT JOIN [Reference].[SubAgents] AS sa ON sa.[Id] = p.[SubAgentsId]
    INNER JOIN [Reference].[Approvers] AS ap ON ap.[Id] = p.[ApproversId]
    LEFT JOIN [Reference].[PromoManagers] AS pm ON pm.[Id] = p.[PromoManagersId]
    LEFT JOIN [Reference].[SalesManagers] AS sm ON sm.[Id] = p.[SalesManagersId]
    LEFT JOIN [Reference].[PromoOfficers] AS po ON po.[Id] = p.[PromoOfficersId]
    INNER JOIN [Reference].[Products] AS pr ON pr.[Id] = p.[ProductsId]
    INNER JOIN [Reference].[ProductCategory] AS pc ON pc.[Id] = pr.[ProductCategoryId]
    INNER JOIN [Reference].[Providers] AS pv ON pv.[Id] = p.[ProvidersId]
    INNER JOIN [Reference].[DistributionChannel] AS dc ON dc.[Id] = p.[DistributionChannelId]
    INNER JOIN [Reference].[SelectionList] AS opt ON opt.[Id] = p.[PaymentOptionId]
    WHERE p.[IsDeleted] = 0;
GO

CREATE OR ALTER VIEW [Transaction].[GroupPolicyView]
AS
    SELECT
        p.[Id], p.[ReferenceNumber], p.[CocNumber], p.[PartnersId], p.[PlatformsId], p.[IssueStatus],
        p.[PolicyBookingStatusId], p.[CocStatusId], p.[PaymentStatusId], p.[ClaimsStatusId],
        p.[AgentsId], p.[SubAgentsId], p.[ApproversId], p.[PromoManagersId], p.[SalesManagersId], p.[PromoOfficersId],
        p.[ProductsId], p.[ProvidersId], p.[DistributionChannelId], p.[PaymentOptionId], p.[AccountTypeId],
        p.[BranchCode], p.[BranchName],
        p.[ProviderPolicyNo], p.[EndorsementNo], p.[TerminationDate], p.[EffectiveDate], p.[IssueDate], p.[Remarks],
        t.[TotalPremium], t.[TotalCoverage], t.[TotalPaid],
        p.[BasicPremium], p.[BasicPremiumCommission], p.[DJDPatricioMarkup], p.[PartnerMarkup], p.[Discount], p.[Taxes],
        p.[DST], p.[VAT], p.[LGT], p.[PT], p.[FST], p.[NotarialFee], p.[Others], p.[PremiumsRemarks],
        p.[CreatedBy], p.[CreatedDateTime], p.[ModifiedBy], p.[ModifiedDateTime],
        pa.[Name] AS [Partners],
        pa.[Code] AS [PartnersCode],
        pl.[Name] AS [Platforms],
        CASE WHEN p.[IssueStatus] = 1 THEN N'Active' ELSE N'Inactive' END AS [IssueStatusTitle],
        pbs.[Name] AS [PolicyBookingStatus],
        cs.[Name] AS [CocStatus],
        ps.[Name] AS [PaymentStatus],
        cls.[Name] AS [ClaimsStatus],
        [dbo].[FormatFullName](ag.[FirstName], ag.[MiddleName], ag.[LastName], ag.[Suffix]) AS [Agents],
        [dbo].[FormatFullName](sa.[FirstName], sa.[MiddleName], sa.[LastName], sa.[Suffix]) AS [SubAgents],
        [dbo].[FormatFullName](ap.[FirstName], ap.[MiddleName], ap.[LastName], ap.[Suffix]) AS [Approvers],
        [dbo].[FormatFullName](pm.[FirstName], pm.[MiddleName], pm.[LastName], pm.[Suffix]) AS [PromoManagers],
        [dbo].[FormatFullName](sm.[FirstName], sm.[MiddleName], sm.[LastName], sm.[Suffix]) AS [SalesManagers],
        [dbo].[FormatFullName](po.[FirstName], po.[MiddleName], po.[LastName], po.[Suffix]) AS [PromoOfficers],
        ISNULL(pc.[Description], pc.[Name]) AS [ProductCategory],
        pr.[ProductCategoryId],
        pr.[Name] AS [Products],
        pv.[Name] AS [Providers],
        dc.[Name] AS [DistributionChannel],
        opt.[Name] AS [PaymentOption],
        act.[Name] AS [AccountType]
    FROM [Transaction].[GroupPolicy] AS p
    CROSS APPLY [Transaction].[GetPolicyTotals](3, p.[Id]) AS t
    INNER JOIN [Reference].[Partners] AS pa ON pa.[Id] = p.[PartnersId]
    INNER JOIN [Static].[Platforms] AS pl ON pl.[Id] = p.[PlatformsId]
    INNER JOIN [Static].[PolicyBookingStatus] AS pbs ON pbs.[Id] = p.[PolicyBookingStatusId]
    INNER JOIN [Static].[CocStatus] AS cs ON cs.[Id] = p.[CocStatusId]
    INNER JOIN [Static].[PaymentStatus] AS ps ON ps.[Id] = p.[PaymentStatusId]
    INNER JOIN [Static].[ClaimsStatus] AS cls ON cls.[Id] = p.[ClaimsStatusId]
    INNER JOIN [Reference].[Agents] AS ag ON ag.[Id] = p.[AgentsId]
    LEFT JOIN [Reference].[SubAgents] AS sa ON sa.[Id] = p.[SubAgentsId]
    INNER JOIN [Reference].[Approvers] AS ap ON ap.[Id] = p.[ApproversId]
    LEFT JOIN [Reference].[PromoManagers] AS pm ON pm.[Id] = p.[PromoManagersId]
    LEFT JOIN [Reference].[SalesManagers] AS sm ON sm.[Id] = p.[SalesManagersId]
    LEFT JOIN [Reference].[PromoOfficers] AS po ON po.[Id] = p.[PromoOfficersId]
    INNER JOIN [Reference].[Products] AS pr ON pr.[Id] = p.[ProductsId]
    INNER JOIN [Reference].[ProductCategory] AS pc ON pc.[Id] = pr.[ProductCategoryId]
    INNER JOIN [Reference].[Providers] AS pv ON pv.[Id] = p.[ProvidersId]
    INNER JOIN [Reference].[DistributionChannel] AS dc ON dc.[Id] = p.[DistributionChannelId]
    INNER JOIN [Reference].[SelectionList] AS opt ON opt.[Id] = p.[PaymentOptionId]
    INNER JOIN [Reference].[SelectionList] AS act ON act.[Id] = p.[AccountTypeId]
    WHERE p.[IsDeleted] = 0;
GO

CREATE OR ALTER VIEW [Transaction].[PolicyBeneficiaryView]
AS
    SELECT
        b.[Id], b.[PolicyId], b.[PolicyTypeId], b.[FirstName], b.[MiddleName], b.[LastName], b.[Suffix],
        [dbo].[FormatFullName](b.[FirstName], b.[MiddleName], b.[LastName], b.[Suffix]) AS [FullName],
        b.[EmailAddress], b.[ContactNumber], b.[DateOfBirth], b.[Relationship],
        b.[CreatedBy], b.[CreatedDateTime], b.[ModifiedBy], b.[ModifiedDateTime],
        pol.[ReferenceNumber], pol.[CocNumber],
        pt.[Name] AS [PolicyType],
        rel.[Name] AS [RelationshipTitle]
    FROM [Transaction].[PolicyBeneficiary] AS b
    INNER JOIN [Transaction].[PolicyView] AS pol ON pol.[PolicyTypeId] = b.[PolicyTypeId] AND pol.[PolicyId] = b.[PolicyId]
    INNER JOIN [Static].[PolicyType] AS pt ON pt.[Id] = b.[PolicyTypeId]
    INNER JOIN [Reference].[SelectionList] AS rel ON rel.[Id] = b.[Relationship]
    WHERE b.[IsDeleted] = 0;
GO

CREATE OR ALTER VIEW [Transaction].[PolicyBenefitsView]
AS
    SELECT
        b.[Id], b.[PolicyId], b.[PolicyTypeId], b.[BenefitsId], b.[CoverageAmount], b.[PremiumAmount], b.[PremiumCommissionAmount],
        b.[CreatedBy], b.[CreatedDateTime], b.[ModifiedBy], b.[ModifiedDateTime],
        pol.[ReferenceNumber], pol.[CocNumber],
        pt.[Name] AS [PolicyType],
        be.[Name] AS [Benefits]
    FROM [Transaction].[PolicyBenefits] AS b
    INNER JOIN [Transaction].[PolicyView] AS pol ON pol.[PolicyTypeId] = b.[PolicyTypeId] AND pol.[PolicyId] = b.[PolicyId]
    INNER JOIN [Static].[PolicyType] AS pt ON pt.[Id] = b.[PolicyTypeId]
    INNER JOIN [Reference].[Benefits] AS be ON be.[Id] = b.[BenefitsId]
    WHERE b.[IsDeleted] = 0;
GO

CREATE OR ALTER VIEW [Transaction].[PolicyDeductiblesView]
AS
    SELECT
        d.[Id], d.[PolicyId], d.[PolicyTypeId], d.[DeductiblesId], d.[Amount],
        d.[CreatedBy], d.[CreatedDateTime], d.[ModifiedBy], d.[ModifiedDateTime],
        pol.[ReferenceNumber], pol.[CocNumber],
        pt.[Name] AS [PolicyType],
        de.[Name] AS [Deductibles]
    FROM [Transaction].[PolicyDeductibles] AS d
    INNER JOIN [Transaction].[PolicyView] AS pol ON pol.[PolicyTypeId] = d.[PolicyTypeId] AND pol.[PolicyId] = d.[PolicyId]
    INNER JOIN [Static].[PolicyType] AS pt ON pt.[Id] = d.[PolicyTypeId]
    INNER JOIN [Reference].[Deductibles] AS de ON de.[Id] = d.[DeductiblesId]
    WHERE d.[IsDeleted] = 0;
GO

CREATE OR ALTER VIEW [Transaction].[PolicyPaymentsView]
AS
    SELECT
        pp.[Id], pp.[PolicyId], pp.[PolicyTypeId], pp.[Amount], pp.[TransactionDateTime], pp.[TransactionCheckNo], pp.[TransactionOrigin],
        pp.[NotificationDateTime], pp.[PaymentMethod], pp.[Notes],
        pp.[CreatedBy], pp.[CreatedDateTime], pp.[ModifiedBy], pp.[ModifiedDateTime],
        pol.[ReferenceNumber], pol.[CocNumber],
        pt.[Name] AS [PolicyType],
        pm.[Name] AS [PaymentMethodTitle]
    FROM [Transaction].[PolicyPayments] AS pp
    INNER JOIN [Transaction].[PolicyView] AS pol ON pol.[PolicyTypeId] = pp.[PolicyTypeId] AND pol.[PolicyId] = pp.[PolicyId]
    INNER JOIN [Static].[PolicyType] AS pt ON pt.[Id] = pp.[PolicyTypeId]
    INNER JOIN [Reference].[SelectionList] AS pm ON pm.[Id] = pp.[PaymentMethod]
    WHERE pp.[IsDeleted] = 0;
GO

/* Attachment types 1 to 4 reference a policy directly; type 5 (Payments) references a payment, which belongs to a policy. */
CREATE OR ALTER VIEW [Transaction].[AttachmentsView]
AS
    SELECT
        a.[Id], a.[ReferenceId], a.[AttachmentTypeId], a.[ContentType], a.[FileName], a.[Attachment],
        a.[CreatedBy], a.[CreatedDateTime], a.[ModifiedBy], a.[ModifiedDateTime],
        att.[Name] AS [AttachmentType],
        pol.[PolicyId],
        pol.[ReferenceNumber] AS [PolicyReferenceNumber],
        pol.[CocNumber] AS [PolicyCocNumber]
    FROM [Transaction].[Attachments] AS a
    INNER JOIN [Static].[AttachmentType] AS att ON att.[Id] = a.[AttachmentTypeId]
    LEFT JOIN [Transaction].[PolicyPayments] AS pay ON a.[AttachmentTypeId] = 5 AND pay.[Id] = a.[ReferenceId]
    INNER JOIN [Transaction].[PolicyView] AS pol
        ON pol.[PolicyTypeId] = CASE a.[AttachmentTypeId] WHEN 1 THEN 1 WHEN 2 THEN 2 WHEN 5 THEN pay.[PolicyTypeId] ELSE 3 END
       AND pol.[PolicyId] = CASE WHEN a.[AttachmentTypeId] = 5 THEN pay.[PolicyId] ELSE a.[ReferenceId] END
    WHERE a.[IsDeleted] = 0;
GO

/* =====================================================================
   Stored procedures
   Parameter names match the C# argument names the repositories send (matching is case-insensitive);
   result columns match the property names of the Models/Result classes.
   Paged procedures return the page, then a second result set with the total record count.
   Business rule errors are raised with the "CustomSQLException: " prefix, which the API turns into HTTP 400.
   ===================================================================== */

/* ---------- Static ---------- */

CREATE OR ALTER PROCEDURE [Static].[GetAddressRegion]
    @id bigint = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT r.[Id], r.[Name], r.[Code]
    FROM [Static].[AddressRegion] AS r
    WHERE r.[IsDeleted] = 0
      AND (@id IS NULL OR r.[Id] = @id)
    ORDER BY r.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Static].[GetAddressRegionDivision]
    @id       bigint = NULL,
    @regionId bigint = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT d.[Id], d.[AddressRegionId], d.[Name], d.[Code]
    FROM [Static].[AddressRegionDivision] AS d
    WHERE d.[IsDeleted] = 0
      AND (@id IS NULL OR d.[Id] = @id)
      AND (@regionId IS NULL OR d.[AddressRegionId] = @regionId)
    ORDER BY d.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Static].[GetAddressCountry]
    @id               bigint = NULL,
    @regionDivisionId bigint = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT c.[Id], c.[AddressRegionDivisionId], c.[Name], c.[Code], c.[PhoneCode], c.[TopLevelDomain], c.[Currency], c.[CurrencyName], c.[Nationality]
    FROM [Static].[AddressCountry] AS c
    WHERE c.[IsDeleted] = 0
      AND (@id IS NULL OR c.[Id] = @id)
      AND (@regionDivisionId IS NULL OR c.[AddressRegionDivisionId] = @regionDivisionId)
    ORDER BY c.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Static].[GetAddressCountryDivision]
    @id        bigint = NULL,
    @countryId bigint = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT d.[Id], d.[AddressCountryId], d.[Name], d.[Acronym], d.[Code]
    FROM [Static].[AddressCountryDivision] AS d
    WHERE d.[IsDeleted] = 0
      AND (@id IS NULL OR d.[Id] = @id)
      AND (@countryId IS NULL OR d.[AddressCountryId] = @countryId)
    ORDER BY d.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Static].[GetAddressState]
    @id                bigint = NULL,
    @countryDivisionId bigint = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT s.[Id], s.[AddressCountryDivisionId], s.[Name], s.[Code]
    FROM [Static].[AddressState] AS s
    WHERE s.[IsDeleted] = 0
      AND (@id IS NULL OR s.[Id] = @id)
      AND (@countryDivisionId IS NULL OR s.[AddressCountryDivisionId] = @countryDivisionId)
    ORDER BY s.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Static].[GetAddressCity]
    @id      bigint = NULL,
    @stateId bigint = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT c.[Id], c.[AddressStateId], c.[Name]
    FROM [Static].[AddressCity] AS c
    WHERE c.[IsDeleted] = 0
      AND (@id IS NULL OR c.[Id] = @id)
      AND (@stateId IS NULL OR c.[AddressStateId] = @stateId)
    ORDER BY c.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Static].[GetAddressTown]
    @id     bigint = NULL,
    @cityId bigint = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT t.[Id], t.[AddressCityId], t.[Name], t.[Code]
    FROM [Static].[AddressTown] AS t
    WHERE t.[IsDeleted] = 0
      AND (@id IS NULL OR t.[Id] = @id)
      AND (@cityId IS NULL OR t.[AddressCityId] = @cityId)
    ORDER BY t.[Id];
END;
GO

/* ---------- Reference ---------- */

CREATE OR ALTER PROCEDURE [Reference].[GetAgents]
    @id                   bigint       = NULL,
    @isActiveOnly         bit          = NULL,
    @DJDPatricioOrAgentId nvarchar(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.[Id], a.[DJDPatricioOrAgentId], a.[FirstName], a.[MiddleName], a.[LastName], a.[Suffix],
        [dbo].[FormatFullName](a.[FirstName], a.[MiddleName], a.[LastName], a.[Suffix]) AS [FullName],
        a.[EmailAddress], a.[ContactNumber], a.[DateOfBirth], a.[Address1], a.[Address2], a.[AddressTownId],
        [Static].[FormatAddress](a.[Address1], a.[Address2], a.[AddressTownId]) AS [Address],
        a.[IsActive], a.[CreatedBy], a.[CreatedDateTime], a.[ModifiedBy], a.[ModifiedDateTime]
    FROM [Reference].[Agents] AS a
    WHERE a.[IsDeleted] = 0
      AND (@id IS NULL OR a.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR a.[IsActive] = 1)
      AND (@DJDPatricioOrAgentId IS NULL OR a.[DJDPatricioOrAgentId] = @DJDPatricioOrAgentId)
    ORDER BY a.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetApprovers]
    @id                   bigint       = NULL,
    @isActiveOnly         bit          = NULL,
    @DJDPatricioOrAgentId nvarchar(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.[Id], a.[DJDPatricioOrAgentId], a.[FirstName], a.[MiddleName], a.[LastName], a.[Suffix],
        [dbo].[FormatFullName](a.[FirstName], a.[MiddleName], a.[LastName], a.[Suffix]) AS [FullName],
        a.[EmailAddress], a.[ContactNumber], a.[DateOfBirth], a.[Address1], a.[Address2], a.[AddressTownId],
        [Static].[FormatAddress](a.[Address1], a.[Address2], a.[AddressTownId]) AS [Address],
        a.[IsActive], a.[CreatedBy], a.[CreatedDateTime], a.[ModifiedBy], a.[ModifiedDateTime]
    FROM [Reference].[Approvers] AS a
    WHERE a.[IsDeleted] = 0
      AND (@id IS NULL OR a.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR a.[IsActive] = 1)
      AND (@DJDPatricioOrAgentId IS NULL OR a.[DJDPatricioOrAgentId] = @DJDPatricioOrAgentId)
    ORDER BY a.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetSubAgents]
    @id                   bigint       = NULL,
    @isActiveOnly         bit          = NULL,
    @DJDPatricioOrAgentId nvarchar(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.[Id], a.[DJDPatricioOrAgentId], a.[FirstName], a.[MiddleName], a.[LastName], a.[Suffix],
        [dbo].[FormatFullName](a.[FirstName], a.[MiddleName], a.[LastName], a.[Suffix]) AS [FullName],
        a.[EmailAddress], a.[ContactNumber], a.[DateOfBirth], a.[Address1], a.[Address2], a.[AddressTownId],
        [Static].[FormatAddress](a.[Address1], a.[Address2], a.[AddressTownId]) AS [Address],
        a.[IsActive], a.[CreatedBy], a.[CreatedDateTime], a.[ModifiedBy], a.[ModifiedDateTime]
    FROM [Reference].[SubAgents] AS a
    WHERE a.[IsDeleted] = 0
      AND (@id IS NULL OR a.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR a.[IsActive] = 1)
      AND (@DJDPatricioOrAgentId IS NULL OR a.[DJDPatricioOrAgentId] = @DJDPatricioOrAgentId)
    ORDER BY a.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetPromoManagers]
    @id                   bigint       = NULL,
    @isActiveOnly         bit          = NULL,
    @DJDPatricioOrAgentId nvarchar(20) = NULL,
    @agentsId             bigint       = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.[Id], a.[AgentsId], a.[DJDPatricioOrAgentId], a.[FirstName], a.[MiddleName], a.[LastName], a.[Suffix],
        [dbo].[FormatFullName](a.[FirstName], a.[MiddleName], a.[LastName], a.[Suffix]) AS [FullName],
        a.[EmailAddress], a.[ContactNumber], a.[DateOfBirth], a.[Address1], a.[Address2], a.[AddressTownId],
        [Static].[FormatAddress](a.[Address1], a.[Address2], a.[AddressTownId]) AS [Address],
        a.[IsActive], a.[CreatedBy], a.[CreatedDateTime], a.[ModifiedBy], a.[ModifiedDateTime]
    FROM [Reference].[PromoManagers] AS a
    WHERE a.[IsDeleted] = 0
      AND (@id IS NULL OR a.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR a.[IsActive] = 1)
      AND (@DJDPatricioOrAgentId IS NULL OR a.[DJDPatricioOrAgentId] = @DJDPatricioOrAgentId)
      AND (@agentsId IS NULL OR a.[AgentsId] = @agentsId)
    ORDER BY a.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetPromoOfficers]
    @id                   bigint       = NULL,
    @isActiveOnly         bit          = NULL,
    @DJDPatricioOrAgentId nvarchar(20) = NULL,
    @agentsId             bigint       = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.[Id], a.[AgentsId], a.[DJDPatricioOrAgentId], a.[FirstName], a.[MiddleName], a.[LastName], a.[Suffix],
        [dbo].[FormatFullName](a.[FirstName], a.[MiddleName], a.[LastName], a.[Suffix]) AS [FullName],
        a.[EmailAddress], a.[ContactNumber], a.[DateOfBirth], a.[Address1], a.[Address2], a.[AddressTownId],
        [Static].[FormatAddress](a.[Address1], a.[Address2], a.[AddressTownId]) AS [Address],
        a.[IsActive], a.[CreatedBy], a.[CreatedDateTime], a.[ModifiedBy], a.[ModifiedDateTime]
    FROM [Reference].[PromoOfficers] AS a
    WHERE a.[IsDeleted] = 0
      AND (@id IS NULL OR a.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR a.[IsActive] = 1)
      AND (@DJDPatricioOrAgentId IS NULL OR a.[DJDPatricioOrAgentId] = @DJDPatricioOrAgentId)
      AND (@agentsId IS NULL OR a.[AgentsId] = @agentsId)
    ORDER BY a.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetSalesManagers]
    @id                   bigint       = NULL,
    @isActiveOnly         bit          = NULL,
    @DJDPatricioOrAgentId nvarchar(20) = NULL,
    @agentsId             bigint       = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.[Id], a.[AgentsId], a.[DJDPatricioOrAgentId], a.[FirstName], a.[MiddleName], a.[LastName], a.[Suffix],
        [dbo].[FormatFullName](a.[FirstName], a.[MiddleName], a.[LastName], a.[Suffix]) AS [FullName],
        a.[EmailAddress], a.[ContactNumber], a.[DateOfBirth], a.[Address1], a.[Address2], a.[AddressTownId],
        [Static].[FormatAddress](a.[Address1], a.[Address2], a.[AddressTownId]) AS [Address],
        a.[IsActive], a.[CreatedBy], a.[CreatedDateTime], a.[ModifiedBy], a.[ModifiedDateTime]
    FROM [Reference].[SalesManagers] AS a
    WHERE a.[IsDeleted] = 0
      AND (@id IS NULL OR a.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR a.[IsActive] = 1)
      AND (@DJDPatricioOrAgentId IS NULL OR a.[DJDPatricioOrAgentId] = @DJDPatricioOrAgentId)
      AND (@agentsId IS NULL OR a.[AgentsId] = @agentsId)
    ORDER BY a.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetClients]
    @id                  bigint       = NULL,
    @isActiveOnly        bit          = NULL,
    @insuranceCustomerNo nvarchar(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.[Id], c.[InsuranceCustomerNo], c.[FirstName], c.[MiddleName], c.[LastName], c.[Suffix],
        [dbo].[FormatFullName](c.[FirstName], c.[MiddleName], c.[LastName], c.[Suffix]) AS [FullName],
        c.[EmailAddress], c.[ContactNumber], c.[DateOfBirth], c.[IsMale], c.[ValidIdPresented], c.[ValidIdPresentedNumber], c.[ValidIdExpiration],
        c.[Address1], c.[Address2], c.[AddressTownId],
        [Static].[FormatAddress](c.[Address1], c.[Address2], c.[AddressTownId]) AS [Address],
        c.[IsActive], c.[CreatedBy], c.[CreatedDateTime], c.[ModifiedBy], c.[ModifiedDateTime]
    FROM [Reference].[Clients] AS c
    WHERE c.[IsDeleted] = 0
      AND (@id IS NULL OR c.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR c.[IsActive] = 1)
      AND (@insuranceCustomerNo IS NULL OR c.[InsuranceCustomerNo] = @insuranceCustomerNo)
    ORDER BY c.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetPartners]
    @id           bigint = NULL,
    @isActiveOnly bit    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.[Id], p.[Name], p.[Description], p.[Code], p.[ContactPerson], p.[EmailAddress], p.[ContactNumber],
        p.[Address1], p.[Address2], p.[AddressTownId],
        [Static].[FormatAddress](p.[Address1], p.[Address2], p.[AddressTownId]) AS [Address],
        p.[IsActive], p.[CreatedBy], p.[CreatedDateTime], p.[ModifiedBy], p.[ModifiedDateTime]
    FROM [Reference].[Partners] AS p
    WHERE p.[IsDeleted] = 0
      AND (@id IS NULL OR p.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR p.[IsActive] = 1)
    ORDER BY p.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetProviders]
    @id           bigint = NULL,
    @isActiveOnly bit    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.[Id], p.[Name], p.[Description], p.[Code], p.[ContactPerson], p.[EmailAddress], p.[ContactNumber],
        p.[Address1], p.[Address2], p.[AddressTownId],
        [Static].[FormatAddress](p.[Address1], p.[Address2], p.[AddressTownId]) AS [Address],
        p.[IsActive], p.[CreatedBy], p.[CreatedDateTime], p.[ModifiedBy], p.[ModifiedDateTime]
    FROM [Reference].[Providers] AS p
    WHERE p.[IsDeleted] = 0
      AND (@id IS NULL OR p.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR p.[IsActive] = 1)
    ORDER BY p.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetBenefits]
    @id           bigint = NULL,
    @isActiveOnly bit    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT b.[Id], b.[Name], b.[Description], b.[Code], b.[IsActive], b.[CreatedBy], b.[CreatedDateTime], b.[ModifiedBy], b.[ModifiedDateTime]
    FROM [Reference].[Benefits] AS b
    WHERE b.[IsDeleted] = 0
      AND (@id IS NULL OR b.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR b.[IsActive] = 1)
    ORDER BY b.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetDeductibles]
    @id           bigint = NULL,
    @isActiveOnly bit    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT d.[Id], d.[Name], d.[Description], d.[Code], d.[IsActive], d.[CreatedBy], d.[CreatedDateTime], d.[ModifiedBy], d.[ModifiedDateTime]
    FROM [Reference].[Deductibles] AS d
    WHERE d.[IsDeleted] = 0
      AND (@id IS NULL OR d.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR d.[IsActive] = 1)
    ORDER BY d.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetDistributionChannel]
    @id           bigint = NULL,
    @isActiveOnly bit    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT d.[Id], d.[Name], d.[Description], d.[Code], d.[IsActive], d.[CreatedBy], d.[CreatedDateTime], d.[ModifiedBy], d.[ModifiedDateTime]
    FROM [Reference].[DistributionChannel] AS d
    WHERE d.[IsDeleted] = 0
      AND (@id IS NULL OR d.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR d.[IsActive] = 1)
    ORDER BY d.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetProductCategory]
    @id           bigint = NULL,
    @isActiveOnly bit    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT c.[Id], c.[Name], c.[Description], c.[Code], c.[IsActive], c.[CreatedBy], c.[CreatedDateTime], c.[ModifiedBy], c.[ModifiedDateTime]
    FROM [Reference].[ProductCategory] AS c
    WHERE c.[IsDeleted] = 0
      AND (@id IS NULL OR c.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR c.[IsActive] = 1)
    ORDER BY c.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetProducts]
    @id                bigint = NULL,
    @isActiveOnly      bit    = NULL,
    @productCategoryId bigint = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.[Id], p.[ProductCategoryId], p.[Name], p.[Description], p.[Code], p.[MinimumAge], p.[MaximumAge],
        p.[MaximumBookingPerYear], p.[MaximumBookingPerDuration], p.[IsActive],
        p.[CreatedBy], p.[CreatedDateTime], p.[ModifiedBy], p.[ModifiedDateTime]
    FROM [Reference].[Products] AS p
    WHERE p.[IsDeleted] = 0
      AND (@id IS NULL OR p.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR p.[IsActive] = 1)
      AND (@productCategoryId IS NULL OR p.[ProductCategoryId] = @productCategoryId)
    ORDER BY p.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetProductBenefits]
    @id           bigint = NULL,
    @isActiveOnly bit    = NULL,
    @productsId   bigint = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pb.[Id], pb.[ProductsId], pb.[BenefitsId], pb.[CoverageAmount], pb.[PremiumAmount], pb.[PremiumCommissionAmount], pb.[IsActive],
        pb.[CreatedBy], pb.[CreatedDateTime], pb.[ModifiedBy], pb.[ModifiedDateTime]
    FROM [Reference].[ProductBenefits] AS pb
    WHERE pb.[IsDeleted] = 0
      AND (@id IS NULL OR pb.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR pb.[IsActive] = 1)
      AND (@productsId IS NULL OR pb.[ProductsId] = @productsId)
    ORDER BY pb.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetProductDeductibles]
    @id           bigint = NULL,
    @isActiveOnly bit    = NULL,
    @productsId   bigint = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pd.[Id], pd.[ProductsId], pd.[DeductiblesId], pd.[Amount], pd.[IsActive],
        pd.[CreatedBy], pd.[CreatedDateTime], pd.[ModifiedBy], pd.[ModifiedDateTime]
    FROM [Reference].[ProductDeductibles] AS pd
    WHERE pd.[IsDeleted] = 0
      AND (@id IS NULL OR pd.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR pd.[IsActive] = 1)
      AND (@productsId IS NULL OR pd.[ProductsId] = @productsId)
    ORDER BY pd.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetProductPremium]
    @id           bigint = NULL,
    @isActiveOnly bit    = NULL,
    @productsId   bigint = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pp.[Id], pp.[ProductsId], pp.[BasicPremium], pp.[BasicPremiumCommission], pp.[DJDPatricioMarkup], pp.[PartnerMarkup],
        pp.[Discount], pp.[Taxes], pp.[DST], pp.[VAT], pp.[LGT], pp.[PT], pp.[FST], pp.[NotarialFee], pp.[Others], pp.[IsActive],
        pp.[CreatedBy], pp.[CreatedDateTime], pp.[ModifiedBy], pp.[ModifiedDateTime]
    FROM [Reference].[ProductPremium] AS pp
    WHERE pp.[IsDeleted] = 0
      AND (@id IS NULL OR pp.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR pp.[IsActive] = 1)
      AND (@productsId IS NULL OR pp.[ProductsId] = @productsId)
    ORDER BY pp.[Id];
END;
GO

CREATE OR ALTER PROCEDURE [Reference].[GetSelectionList]
    @id              bigint = NULL,
    @isActiveOnly    bit    = NULL,
    @selectionTypeId bigint = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.[Id], s.[SelectionTypeId], s.[Name], s.[Description], s.[IsActive],
        s.[CreatedBy], s.[CreatedDateTime], s.[ModifiedBy], s.[ModifiedDateTime]
    FROM [Reference].[SelectionList] AS s
    WHERE s.[IsDeleted] = 0
      AND (@id IS NULL OR s.[Id] = @id)
      AND (ISNULL(@isActiveOnly, 0) = 0 OR s.[IsActive] = 1)
      AND (@selectionTypeId IS NULL OR s.[SelectionTypeId] = @selectionTypeId)
    ORDER BY s.[Id];
END;
GO

/* ---------- Transaction: internal helper ---------- */

/* Recomputes a policy's payment status after its premium, benefits or payments change. Cancelled stays cancelled. */
CREATE OR ALTER PROCEDURE [Transaction].[SetPolicyPaymentStatus]
    @PolicyTypeId bigint,
    @PolicyId     bigint,
    @UserId       bigint
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PaymentStatusId bigint;

    SELECT @PaymentStatusId = [Transaction].[GetPaymentStatusId](t.[TotalPremium], t.[TotalPaid])
    FROM [Transaction].[GetPolicyTotals](@PolicyTypeId, @PolicyId) AS t;

    IF @PolicyTypeId = 1
        UPDATE [Transaction].[IndividualPolicy]
        SET [PaymentStatusId] = @PaymentStatusId, [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
        WHERE [Id] = @PolicyId AND [PaymentStatusId] NOT IN (4, @PaymentStatusId);
    ELSE IF @PolicyTypeId = 2
        UPDATE [Transaction].[PartnerPolicy]
        SET [PaymentStatusId] = @PaymentStatusId, [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
        WHERE [Id] = @PolicyId AND [PaymentStatusId] NOT IN (4, @PaymentStatusId);
    ELSE IF @PolicyTypeId = 3
        UPDATE [Transaction].[GroupPolicy]
        SET [PaymentStatusId] = @PaymentStatusId, [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
        WHERE [Id] = @PolicyId AND [PaymentStatusId] NOT IN (4, @PaymentStatusId);
END;
GO

/* ---------- Transaction: Get ---------- */

CREATE OR ALTER PROCEDURE [Transaction].[GetIndividualPolicy]
    @id                    bigint         = NULL,
    @referenceNumber       nvarchar(12)   = NULL,
    @cocNumber             nvarchar(12)   = NULL,
    @partnersId            bigint         = NULL,
    @clientsId             bigint         = NULL,
    @issueStatus           bit            = NULL,
    @policyBookingStatusId nvarchar(4000) = NULL,
    @cocStatusId           nvarchar(4000) = NULL,
    @paymentStatusId       nvarchar(4000) = NULL,
    @claimsStatusId        nvarchar(4000) = NULL,
    @pageNumber            int            = 1,
    @pageSize              int            = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT p.[Id]
    FROM [Transaction].[IndividualPolicy] AS p
    WHERE p.[IsDeleted] = 0
      AND (@id IS NULL OR p.[Id] = @id)
      AND (@referenceNumber IS NULL OR p.[ReferenceNumber] = @referenceNumber)
      AND (@cocNumber IS NULL OR p.[CocNumber] = @cocNumber)
      AND (@partnersId IS NULL OR p.[PartnersId] = @partnersId)
      AND (@clientsId IS NULL OR p.[ClientsId] = @clientsId)
      AND (@issueStatus IS NULL OR p.[IssueStatus] = @issueStatus)
      AND (NULLIF(@policyBookingStatusId, N'') IS NULL OR p.[PolicyBookingStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@policyBookingStatusId)))
      AND (NULLIF(@cocStatusId, N'') IS NULL OR p.[CocStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@cocStatusId)))
      AND (NULLIF(@paymentStatusId, N'') IS NULL OR p.[PaymentStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@paymentStatusId)))
      AND (NULLIF(@claimsStatusId, N'') IS NULL OR p.[ClaimsStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@claimsStatusId)))
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT
        p.[Id], p.[ReferenceNumber], p.[CocNumber], p.[ClientsId], p.[PartnersId], p.[PlatformsId], p.[IssueStatus],
        p.[PolicyBookingStatusId], p.[CocStatusId], p.[PaymentStatusId], p.[ClaimsStatusId],
        p.[AgentsId], p.[SubAgentsId], p.[ApproversId], p.[PromoManagersId], p.[SalesManagersId], p.[PromoOfficersId],
        p.[ProductsId], p.[ProvidersId], p.[DistributionChannelId], p.[PaymentOptionId],
        p.[ProviderPolicyNo], p.[EndorsementNo], p.[TerminationDate], p.[EffectiveDate], p.[IssueDate], p.[Remarks],
        t.[TotalPremium], t.[TotalCoverage], t.[TotalPaid],
        p.[BasicPremium], p.[BasicPremiumCommission], p.[DJDPatricioMarkup], p.[PartnerMarkup], p.[Discount], p.[Taxes],
        p.[DST], p.[VAT], p.[LGT], p.[PT], p.[FST], p.[NotarialFee], p.[Others], p.[PremiumsRemarks],
        p.[CreatedBy], p.[CreatedDateTime], p.[ModifiedBy], p.[ModifiedDateTime]
    FROM @Filtered AS f
    INNER JOIN [Transaction].[IndividualPolicy] AS p ON p.[Id] = f.[Id]
    CROSS APPLY [Transaction].[GetPolicyTotals](1, p.[Id]) AS t
    ORDER BY p.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[GetPartnerPolicy]
    @id                    bigint         = NULL,
    @referenceNumber       nvarchar(12)   = NULL,
    @cocNumber             nvarchar(12)   = NULL,
    @partnersId            bigint         = NULL,
    @issueStatus           bit            = NULL,
    @policyBookingStatusId nvarchar(4000) = NULL,
    @cocStatusId           nvarchar(4000) = NULL,
    @paymentStatusId       nvarchar(4000) = NULL,
    @claimsStatusId        nvarchar(4000) = NULL,
    @pageNumber            int            = 1,
    @pageSize              int            = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT p.[Id]
    FROM [Transaction].[PartnerPolicy] AS p
    WHERE p.[IsDeleted] = 0
      AND (@id IS NULL OR p.[Id] = @id)
      AND (@referenceNumber IS NULL OR p.[ReferenceNumber] = @referenceNumber)
      AND (@cocNumber IS NULL OR p.[CocNumber] = @cocNumber)
      AND (@partnersId IS NULL OR p.[PartnersId] = @partnersId)
      AND (@issueStatus IS NULL OR p.[IssueStatus] = @issueStatus)
      AND (NULLIF(@policyBookingStatusId, N'') IS NULL OR p.[PolicyBookingStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@policyBookingStatusId)))
      AND (NULLIF(@cocStatusId, N'') IS NULL OR p.[CocStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@cocStatusId)))
      AND (NULLIF(@paymentStatusId, N'') IS NULL OR p.[PaymentStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@paymentStatusId)))
      AND (NULLIF(@claimsStatusId, N'') IS NULL OR p.[ClaimsStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@claimsStatusId)))
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT
        p.[Id], p.[ReferenceNumber], p.[CocNumber], p.[PartnersId], p.[PlatformsId], p.[IssueStatus],
        p.[PolicyBookingStatusId], p.[CocStatusId], p.[PaymentStatusId], p.[ClaimsStatusId],
        p.[AgentsId], p.[SubAgentsId], p.[ApproversId], p.[PromoManagersId], p.[SalesManagersId], p.[PromoOfficersId],
        p.[ProductsId], p.[ProvidersId], p.[DistributionChannelId], p.[PaymentOptionId],
        p.[ProviderPolicyNo], p.[EndorsementNo], p.[TerminationDate], p.[EffectiveDate], p.[IssueDate], p.[Remarks],
        t.[TotalPremium], t.[TotalCoverage], t.[TotalPaid],
        p.[BasicPremium], p.[BasicPremiumCommission], p.[DJDPatricioMarkup], p.[PartnerMarkup], p.[Discount], p.[Taxes],
        p.[DST], p.[VAT], p.[LGT], p.[PT], p.[FST], p.[NotarialFee], p.[Others], p.[PremiumsRemarks],
        p.[CreatedBy], p.[CreatedDateTime], p.[ModifiedBy], p.[ModifiedDateTime]
    FROM @Filtered AS f
    INNER JOIN [Transaction].[PartnerPolicy] AS p ON p.[Id] = f.[Id]
    CROSS APPLY [Transaction].[GetPolicyTotals](2, p.[Id]) AS t
    ORDER BY p.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[GetGroupPolicy]
    @id                    bigint         = NULL,
    @referenceNumber       nvarchar(12)   = NULL,
    @cocNumber             nvarchar(12)   = NULL,
    @partnersId            bigint         = NULL,
    @issueStatus           bit            = NULL,
    @policyBookingStatusId nvarchar(4000) = NULL,
    @cocStatusId           nvarchar(4000) = NULL,
    @paymentStatusId       nvarchar(4000) = NULL,
    @claimsStatusId        nvarchar(4000) = NULL,
    @pageNumber            int            = 1,
    @pageSize              int            = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT p.[Id]
    FROM [Transaction].[GroupPolicy] AS p
    WHERE p.[IsDeleted] = 0
      AND (@id IS NULL OR p.[Id] = @id)
      AND (@referenceNumber IS NULL OR p.[ReferenceNumber] = @referenceNumber)
      AND (@cocNumber IS NULL OR p.[CocNumber] = @cocNumber)
      AND (@partnersId IS NULL OR p.[PartnersId] = @partnersId)
      AND (@issueStatus IS NULL OR p.[IssueStatus] = @issueStatus)
      AND (NULLIF(@policyBookingStatusId, N'') IS NULL OR p.[PolicyBookingStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@policyBookingStatusId)))
      AND (NULLIF(@cocStatusId, N'') IS NULL OR p.[CocStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@cocStatusId)))
      AND (NULLIF(@paymentStatusId, N'') IS NULL OR p.[PaymentStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@paymentStatusId)))
      AND (NULLIF(@claimsStatusId, N'') IS NULL OR p.[ClaimsStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@claimsStatusId)))
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT
        p.[Id], p.[ReferenceNumber], p.[CocNumber], p.[PartnersId], p.[PlatformsId], p.[IssueStatus],
        p.[PolicyBookingStatusId], p.[CocStatusId], p.[PaymentStatusId], p.[ClaimsStatusId],
        p.[AgentsId], p.[SubAgentsId], p.[ApproversId], p.[PromoManagersId], p.[SalesManagersId], p.[PromoOfficersId],
        p.[ProductsId], p.[ProvidersId], p.[DistributionChannelId], p.[PaymentOptionId], p.[AccountTypeId],
        p.[BranchCode], p.[BranchName],
        p.[ProviderPolicyNo], p.[EndorsementNo], p.[TerminationDate], p.[EffectiveDate], p.[IssueDate], p.[Remarks],
        t.[TotalPremium], t.[TotalCoverage], t.[TotalPaid],
        p.[BasicPremium], p.[BasicPremiumCommission], p.[DJDPatricioMarkup], p.[PartnerMarkup], p.[Discount], p.[Taxes],
        p.[DST], p.[VAT], p.[LGT], p.[PT], p.[FST], p.[NotarialFee], p.[Others], p.[PremiumsRemarks],
        p.[CreatedBy], p.[CreatedDateTime], p.[ModifiedBy], p.[ModifiedDateTime]
    FROM @Filtered AS f
    INNER JOIN [Transaction].[GroupPolicy] AS p ON p.[Id] = f.[Id]
    CROSS APPLY [Transaction].[GetPolicyTotals](3, p.[Id]) AS t
    ORDER BY p.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[GetPolicyBeneficiary]
    @id           bigint = NULL,
    @policyId     bigint = NULL,
    @policyTypeId bigint = NULL,
    @pageNumber   int    = 1,
    @pageSize     int    = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT b.[Id]
    FROM [Transaction].[PolicyBeneficiary] AS b
    WHERE b.[IsDeleted] = 0
      AND (@id IS NULL OR b.[Id] = @id)
      AND (@policyId IS NULL OR b.[PolicyId] = @policyId)
      AND (@policyTypeId IS NULL OR b.[PolicyTypeId] = @policyTypeId)
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT
        b.[Id], b.[PolicyId], b.[PolicyTypeId], b.[FirstName], b.[MiddleName], b.[LastName], b.[Suffix],
        [dbo].[FormatFullName](b.[FirstName], b.[MiddleName], b.[LastName], b.[Suffix]) AS [FullName],
        b.[EmailAddress], b.[ContactNumber], b.[DateOfBirth], b.[Relationship],
        b.[CreatedBy], b.[CreatedDateTime], b.[ModifiedBy], b.[ModifiedDateTime]
    FROM @Filtered AS f
    INNER JOIN [Transaction].[PolicyBeneficiary] AS b ON b.[Id] = f.[Id]
    ORDER BY b.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[GetPolicyBenefits]
    @id           bigint = NULL,
    @policyId     bigint = NULL,
    @policyTypeId bigint = NULL,
    @pageNumber   int    = 1,
    @pageSize     int    = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT b.[Id]
    FROM [Transaction].[PolicyBenefits] AS b
    WHERE b.[IsDeleted] = 0
      AND (@id IS NULL OR b.[Id] = @id)
      AND (@policyId IS NULL OR b.[PolicyId] = @policyId)
      AND (@policyTypeId IS NULL OR b.[PolicyTypeId] = @policyTypeId)
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT
        b.[Id], b.[PolicyId], b.[PolicyTypeId], b.[BenefitsId], b.[CoverageAmount], b.[PremiumAmount], b.[PremiumCommissionAmount],
        b.[CreatedBy], b.[CreatedDateTime], b.[ModifiedBy], b.[ModifiedDateTime]
    FROM @Filtered AS f
    INNER JOIN [Transaction].[PolicyBenefits] AS b ON b.[Id] = f.[Id]
    ORDER BY b.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[GetPolicyDeductibles]
    @id           bigint = NULL,
    @policyId     bigint = NULL,
    @policyTypeId bigint = NULL,
    @pageNumber   int    = 1,
    @pageSize     int    = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT d.[Id]
    FROM [Transaction].[PolicyDeductibles] AS d
    WHERE d.[IsDeleted] = 0
      AND (@id IS NULL OR d.[Id] = @id)
      AND (@policyId IS NULL OR d.[PolicyId] = @policyId)
      AND (@policyTypeId IS NULL OR d.[PolicyTypeId] = @policyTypeId)
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT
        d.[Id], d.[PolicyId], d.[PolicyTypeId], d.[DeductiblesId], d.[Amount],
        d.[CreatedBy], d.[CreatedDateTime], d.[ModifiedBy], d.[ModifiedDateTime]
    FROM @Filtered AS f
    INNER JOIN [Transaction].[PolicyDeductibles] AS d ON d.[Id] = f.[Id]
    ORDER BY d.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[GetPolicyPayments]
    @id           bigint = NULL,
    @policyId     bigint = NULL,
    @policyTypeId bigint = NULL,
    @pageNumber   int    = 1,
    @pageSize     int    = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT pp.[Id]
    FROM [Transaction].[PolicyPayments] AS pp
    WHERE pp.[IsDeleted] = 0
      AND (@id IS NULL OR pp.[Id] = @id)
      AND (@policyId IS NULL OR pp.[PolicyId] = @policyId)
      AND (@policyTypeId IS NULL OR pp.[PolicyTypeId] = @policyTypeId)
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT
        pp.[Id], pp.[PolicyId], pp.[PolicyTypeId], pp.[Amount], pp.[TransactionDateTime], pp.[TransactionCheckNo], pp.[TransactionOrigin],
        pp.[NotificationDateTime], pp.[PaymentMethod], pp.[Notes],
        pp.[CreatedBy], pp.[CreatedDateTime], pp.[ModifiedBy], pp.[ModifiedDateTime]
    FROM @Filtered AS f
    INNER JOIN [Transaction].[PolicyPayments] AS pp ON pp.[Id] = f.[Id]
    ORDER BY pp.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[GetAttachments]
    @id               bigint = NULL,
    @referenceId      bigint = NULL,
    @attachmentTypeId bigint = NULL,
    @pageNumber       int    = 1,
    @pageSize         int    = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT a.[Id]
    FROM [Transaction].[Attachments] AS a
    WHERE a.[IsDeleted] = 0
      AND (@id IS NULL OR a.[Id] = @id)
      AND (@referenceId IS NULL OR a.[ReferenceId] = @referenceId)
      AND (@attachmentTypeId IS NULL OR a.[AttachmentTypeId] = @attachmentTypeId)
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT
        a.[Id], a.[ReferenceId], a.[AttachmentTypeId], a.[ContentType], a.[FileName], a.[Attachment],
        a.[CreatedBy], a.[CreatedDateTime], a.[ModifiedBy], a.[ModifiedDateTime]
    FROM @Filtered AS f
    INNER JOIN [Transaction].[Attachments] AS a ON a.[Id] = f.[Id]
    ORDER BY a.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

/* ---------- Transaction: Get from views ---------- */

CREATE OR ALTER PROCEDURE [Transaction].[GetIndividualPolicyView]
    @id                         bigint         = NULL,
    @referenceNumber            nvarchar(12)   = NULL,
    @cocNumber                  nvarchar(12)   = NULL,
    @partnersId                 bigint         = NULL,
    @clientsId                  bigint         = NULL,
    @issueStatus                bit            = NULL,
    @policyBookingStatusId      nvarchar(4000) = NULL,
    @cocStatusId                nvarchar(4000) = NULL,
    @paymentStatusId            nvarchar(4000) = NULL,
    @claimsStatusId             nvarchar(4000) = NULL,
    @clientsInsuranceCustomerNo nvarchar(20)   = NULL,
    @pageNumber                 int            = 1,
    @pageSize                   int            = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT p.[Id]
    FROM [Transaction].[IndividualPolicy] AS p
    INNER JOIN [Reference].[Clients] AS c ON c.[Id] = p.[ClientsId]
    WHERE p.[IsDeleted] = 0
      AND (@id IS NULL OR p.[Id] = @id)
      AND (@referenceNumber IS NULL OR p.[ReferenceNumber] = @referenceNumber)
      AND (@cocNumber IS NULL OR p.[CocNumber] = @cocNumber)
      AND (@partnersId IS NULL OR p.[PartnersId] = @partnersId)
      AND (@clientsId IS NULL OR p.[ClientsId] = @clientsId)
      AND (@issueStatus IS NULL OR p.[IssueStatus] = @issueStatus)
      AND (NULLIF(@policyBookingStatusId, N'') IS NULL OR p.[PolicyBookingStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@policyBookingStatusId)))
      AND (NULLIF(@cocStatusId, N'') IS NULL OR p.[CocStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@cocStatusId)))
      AND (NULLIF(@paymentStatusId, N'') IS NULL OR p.[PaymentStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@paymentStatusId)))
      AND (NULLIF(@claimsStatusId, N'') IS NULL OR p.[ClaimsStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@claimsStatusId)))
      AND (@clientsInsuranceCustomerNo IS NULL OR c.[InsuranceCustomerNo] = @clientsInsuranceCustomerNo)
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT v.*
    FROM @Filtered AS f
    INNER JOIN [Transaction].[IndividualPolicyView] AS v ON v.[Id] = f.[Id]
    ORDER BY v.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[GetPartnerPolicyView]
    @id                    bigint         = NULL,
    @referenceNumber       nvarchar(12)   = NULL,
    @cocNumber             nvarchar(12)   = NULL,
    @partnersId            bigint         = NULL,
    @issueStatus           bit            = NULL,
    @policyBookingStatusId nvarchar(4000) = NULL,
    @cocStatusId           nvarchar(4000) = NULL,
    @paymentStatusId       nvarchar(4000) = NULL,
    @claimsStatusId        nvarchar(4000) = NULL,
    @partnersCode          nvarchar(30)   = NULL,
    @pageNumber            int            = 1,
    @pageSize              int            = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT p.[Id]
    FROM [Transaction].[PartnerPolicy] AS p
    INNER JOIN [Reference].[Partners] AS pa ON pa.[Id] = p.[PartnersId]
    WHERE p.[IsDeleted] = 0
      AND (@id IS NULL OR p.[Id] = @id)
      AND (@referenceNumber IS NULL OR p.[ReferenceNumber] = @referenceNumber)
      AND (@cocNumber IS NULL OR p.[CocNumber] = @cocNumber)
      AND (@partnersId IS NULL OR p.[PartnersId] = @partnersId)
      AND (@issueStatus IS NULL OR p.[IssueStatus] = @issueStatus)
      AND (NULLIF(@policyBookingStatusId, N'') IS NULL OR p.[PolicyBookingStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@policyBookingStatusId)))
      AND (NULLIF(@cocStatusId, N'') IS NULL OR p.[CocStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@cocStatusId)))
      AND (NULLIF(@paymentStatusId, N'') IS NULL OR p.[PaymentStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@paymentStatusId)))
      AND (NULLIF(@claimsStatusId, N'') IS NULL OR p.[ClaimsStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@claimsStatusId)))
      AND (@partnersCode IS NULL OR pa.[Code] = @partnersCode)
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT v.*
    FROM @Filtered AS f
    INNER JOIN [Transaction].[PartnerPolicyView] AS v ON v.[Id] = f.[Id]
    ORDER BY v.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[GetGroupPolicyView]
    @id                    bigint         = NULL,
    @referenceNumber       nvarchar(12)   = NULL,
    @cocNumber             nvarchar(12)   = NULL,
    @partnersId            bigint         = NULL,
    @issueStatus           bit            = NULL,
    @policyBookingStatusId nvarchar(4000) = NULL,
    @cocStatusId           nvarchar(4000) = NULL,
    @paymentStatusId       nvarchar(4000) = NULL,
    @claimsStatusId        nvarchar(4000) = NULL,
    @partnersCode          nvarchar(30)   = NULL,
    @pageNumber            int            = 1,
    @pageSize              int            = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT p.[Id]
    FROM [Transaction].[GroupPolicy] AS p
    INNER JOIN [Reference].[Partners] AS pa ON pa.[Id] = p.[PartnersId]
    WHERE p.[IsDeleted] = 0
      AND (@id IS NULL OR p.[Id] = @id)
      AND (@referenceNumber IS NULL OR p.[ReferenceNumber] = @referenceNumber)
      AND (@cocNumber IS NULL OR p.[CocNumber] = @cocNumber)
      AND (@partnersId IS NULL OR p.[PartnersId] = @partnersId)
      AND (@issueStatus IS NULL OR p.[IssueStatus] = @issueStatus)
      AND (NULLIF(@policyBookingStatusId, N'') IS NULL OR p.[PolicyBookingStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@policyBookingStatusId)))
      AND (NULLIF(@cocStatusId, N'') IS NULL OR p.[CocStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@cocStatusId)))
      AND (NULLIF(@paymentStatusId, N'') IS NULL OR p.[PaymentStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@paymentStatusId)))
      AND (NULLIF(@claimsStatusId, N'') IS NULL OR p.[ClaimsStatusId] IN (SELECT [Id] FROM [dbo].[SplitIds](@claimsStatusId)))
      AND (@partnersCode IS NULL OR pa.[Code] = @partnersCode)
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT v.*
    FROM @Filtered AS f
    INNER JOIN [Transaction].[GroupPolicyView] AS v ON v.[Id] = f.[Id]
    ORDER BY v.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[GetPolicyBeneficiaryView]
    @id           bigint = NULL,
    @policyId     bigint = NULL,
    @policyTypeId bigint = NULL,
    @pageNumber   int    = 1,
    @pageSize     int    = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT v.[Id]
    FROM [Transaction].[PolicyBeneficiaryView] AS v
    WHERE (@id IS NULL OR v.[Id] = @id)
      AND (@policyId IS NULL OR v.[PolicyId] = @policyId)
      AND (@policyTypeId IS NULL OR v.[PolicyTypeId] = @policyTypeId)
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT v.*
    FROM @Filtered AS f
    INNER JOIN [Transaction].[PolicyBeneficiaryView] AS v ON v.[Id] = f.[Id]
    ORDER BY v.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[GetPolicyBenefitsView]
    @id           bigint = NULL,
    @policyId     bigint = NULL,
    @policyTypeId bigint = NULL,
    @pageNumber   int    = 1,
    @pageSize     int    = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT v.[Id]
    FROM [Transaction].[PolicyBenefitsView] AS v
    WHERE (@id IS NULL OR v.[Id] = @id)
      AND (@policyId IS NULL OR v.[PolicyId] = @policyId)
      AND (@policyTypeId IS NULL OR v.[PolicyTypeId] = @policyTypeId)
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT v.*
    FROM @Filtered AS f
    INNER JOIN [Transaction].[PolicyBenefitsView] AS v ON v.[Id] = f.[Id]
    ORDER BY v.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[GetPolicyDeductiblesView]
    @id           bigint = NULL,
    @policyId     bigint = NULL,
    @policyTypeId bigint = NULL,
    @pageNumber   int    = 1,
    @pageSize     int    = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT v.[Id]
    FROM [Transaction].[PolicyDeductiblesView] AS v
    WHERE (@id IS NULL OR v.[Id] = @id)
      AND (@policyId IS NULL OR v.[PolicyId] = @policyId)
      AND (@policyTypeId IS NULL OR v.[PolicyTypeId] = @policyTypeId)
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT v.*
    FROM @Filtered AS f
    INNER JOIN [Transaction].[PolicyDeductiblesView] AS v ON v.[Id] = f.[Id]
    ORDER BY v.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[GetPolicyPaymentsView]
    @id           bigint = NULL,
    @policyId     bigint = NULL,
    @policyTypeId bigint = NULL,
    @pageNumber   int    = 1,
    @pageSize     int    = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT v.[Id]
    FROM [Transaction].[PolicyPaymentsView] AS v
    WHERE (@id IS NULL OR v.[Id] = @id)
      AND (@policyId IS NULL OR v.[PolicyId] = @policyId)
      AND (@policyTypeId IS NULL OR v.[PolicyTypeId] = @policyTypeId)
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT v.*
    FROM @Filtered AS f
    INNER JOIN [Transaction].[PolicyPaymentsView] AS v ON v.[Id] = f.[Id]
    ORDER BY v.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[GetAttachmentsView]
    @id               bigint = NULL,
    @referenceId      bigint = NULL,
    @attachmentTypeId bigint = NULL,
    @pageNumber       int    = 1,
    @pageSize         int    = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Filtered TABLE ([Id] bigint NOT NULL PRIMARY KEY);
    DECLARE @TotalRecords bigint, @RowOffset bigint, @RowFetch bigint;

    INSERT INTO @Filtered ([Id])
    SELECT v.[Id]
    FROM [Transaction].[AttachmentsView] AS v
    WHERE (@id IS NULL OR v.[Id] = @id)
      AND (@referenceId IS NULL OR v.[ReferenceId] = @referenceId)
      AND (@attachmentTypeId IS NULL OR v.[AttachmentTypeId] = @attachmentTypeId)
    OPTION (RECOMPILE);

    SET @TotalRecords = @@ROWCOUNT;
    SELECT @RowOffset = [RowOffset], @RowFetch = [RowFetch] FROM [dbo].[GetPagination](@pageNumber, @pageSize, @TotalRecords);

    SELECT v.*
    FROM @Filtered AS f
    INNER JOIN [Transaction].[AttachmentsView] AS v ON v.[Id] = f.[Id]
    ORDER BY v.[Id]
    OFFSET @RowOffset ROWS FETCH NEXT @RowFetch ROWS ONLY;

    SELECT @TotalRecords AS [TotalRecords];
END;
GO

/* ---------- Transaction: Post ---------- */

CREATE OR ALTER PROCEDURE [Transaction].[PostIndividualPolicy]
    @ClientsId              bigint,
    @PartnersId             bigint,
    @PlatformsId            bigint,
    @PolicyBookingStatusId  bigint,
    @CocStatusId            bigint,
    @ClaimsStatusId         bigint,
    @AgentsId               bigint,
    @SubAgentsId            bigint,
    @ApproversId            bigint,
    @PromoManagersId        bigint,
    @SalesManagersId        bigint,
    @PromoOfficersId        bigint,
    @ProductsId             bigint,
    @ProvidersId            bigint,
    @DistributionChannelId  bigint,
    @PaymentOptionId        bigint,
    @ProviderPolicyNo       nvarchar(50),
    @EndorsementNo          nvarchar(50),
    @TerminationDate        date,
    @EffectiveDate          date,
    @IssueDate              date,
    @Remarks                nvarchar(500),
    @BasicPremium           decimal(18, 2),
    @BasicPremiumCommission decimal(18, 2),
    @DJDPatricioMarkup      decimal(18, 2),
    @PartnerMarkup          decimal(18, 2),
    @Discount               decimal(18, 2),
    @Taxes                  decimal(18, 2),
    @DST                    decimal(18, 2),
    @VAT                    decimal(18, 2),
    @LGT                    decimal(18, 2),
    @PT                     decimal(18, 2),
    @FST                    decimal(18, 2),
    @NotarialFee            decimal(18, 2),
    @Others                 decimal(18, 2),
    @PremiumsRemarks        nvarchar(500),
    @UserId                 bigint
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @EffectiveDate > @TerminationDate
        THROW 50001, N'CustomSQLException: EffectiveDate must not be later than TerminationDate', 1;

    DECLARE @ClientAge int, @MinimumAge int, @MaximumAge int, @MaximumBookingPerYear int;

    SELECT @ClientAge = DATEDIFF(YEAR, c.[DateOfBirth], @EffectiveDate)
                        - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, c.[DateOfBirth], @EffectiveDate), c.[DateOfBirth]) > @EffectiveDate THEN 1 ELSE 0 END
    FROM [Reference].[Clients] AS c
    WHERE c.[Id] = @ClientsId AND c.[IsDeleted] = 0;

    SELECT @MinimumAge = p.[MinimumAge], @MaximumAge = p.[MaximumAge], @MaximumBookingPerYear = p.[MaximumBookingPerYear]
    FROM [Reference].[Products] AS p
    WHERE p.[Id] = @ProductsId AND p.[IsDeleted] = 0;

    IF @ClientAge IS NOT NULL AND ((@MinimumAge IS NOT NULL AND @ClientAge < @MinimumAge) OR (@MaximumAge IS NOT NULL AND @ClientAge > @MaximumAge))
        THROW 50002, N'CustomSQLException: Client age is outside the age range allowed by the product', 1;

    IF @MaximumBookingPerYear IS NOT NULL
       AND (SELECT COUNT(*) FROM [Transaction].[IndividualPolicy] AS ip
            WHERE ip.[ClientsId] = @ClientsId AND ip.[ProductsId] = @ProductsId AND ip.[IsDeleted] = 0
              AND YEAR(ip.[EffectiveDate]) = YEAR(@EffectiveDate)) >= @MaximumBookingPerYear
        THROW 50003, N'CustomSQLException: Client has reached the maximum bookings per year for this product', 1;

    DECLARE @PolicyNumber bigint = NEXT VALUE FOR [Transaction].[IndividualPolicyNumberSequence];
    DECLARE @CocSequence bigint = NEXT VALUE FOR [Transaction].[CocNumberSequence];
    DECLARE @Id bigint;

    BEGIN TRANSACTION;

    INSERT INTO [Transaction].[IndividualPolicy]
    (
        [ReferenceNumber], [CocNumber], [ClientsId], [PartnersId], [PlatformsId], [IssueStatus],
        [PolicyBookingStatusId], [CocStatusId], [PaymentStatusId], [ClaimsStatusId],
        [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId],
        [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId],
        [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks],
        [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes],
        [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks],
        [CreatedBy], [ModifiedBy]
    )
    VALUES
    (
        [Transaction].[FormatReferenceNumber](1, @PolicyNumber), [Transaction].[FormatCocNumber](@CocSequence),
        @ClientsId, @PartnersId, @PlatformsId, 1,
        @PolicyBookingStatusId, @CocStatusId, 2, @ClaimsStatusId,
        @AgentsId, @SubAgentsId, @ApproversId, @PromoManagersId, @SalesManagersId, @PromoOfficersId,
        @ProductsId, @ProvidersId, @DistributionChannelId, @PaymentOptionId,
        @ProviderPolicyNo, @EndorsementNo, @TerminationDate, @EffectiveDate, @IssueDate, @Remarks,
        ISNULL(@BasicPremium, 0), ISNULL(@BasicPremiumCommission, 0), ISNULL(@DJDPatricioMarkup, 0), ISNULL(@PartnerMarkup, 0), ISNULL(@Discount, 0), ISNULL(@Taxes, 0),
        ISNULL(@DST, 0), ISNULL(@VAT, 0), ISNULL(@LGT, 0), ISNULL(@PT, 0), ISNULL(@FST, 0), ISNULL(@NotarialFee, 0), ISNULL(@Others, 0), @PremiumsRemarks,
        @UserId, @UserId
    );

    SET @Id = CAST(SCOPE_IDENTITY() AS bigint);
    EXEC [Transaction].[SetPolicyPaymentStatus] @PolicyTypeId = 1, @PolicyId = @Id, @UserId = @UserId;

    COMMIT TRANSACTION;

    SELECT @Id AS [Id];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[PostPartnerPolicy]
    @PartnersId             bigint,
    @PlatformsId            bigint,
    @PolicyBookingStatusId  bigint,
    @CocStatusId            bigint,
    @ClaimsStatusId         bigint,
    @AgentsId               bigint,
    @SubAgentsId            bigint,
    @ApproversId            bigint,
    @PromoManagersId        bigint,
    @SalesManagersId        bigint,
    @PromoOfficersId        bigint,
    @ProductsId             bigint,
    @ProvidersId            bigint,
    @DistributionChannelId  bigint,
    @PaymentOptionId        bigint,
    @ProviderPolicyNo       nvarchar(50),
    @EndorsementNo          nvarchar(50),
    @TerminationDate        date,
    @EffectiveDate          date,
    @IssueDate              date,
    @Remarks                nvarchar(500),
    @BasicPremium           decimal(18, 2),
    @BasicPremiumCommission decimal(18, 2),
    @DJDPatricioMarkup      decimal(18, 2),
    @PartnerMarkup          decimal(18, 2),
    @Discount               decimal(18, 2),
    @Taxes                  decimal(18, 2),
    @DST                    decimal(18, 2),
    @VAT                    decimal(18, 2),
    @LGT                    decimal(18, 2),
    @PT                     decimal(18, 2),
    @FST                    decimal(18, 2),
    @NotarialFee            decimal(18, 2),
    @Others                 decimal(18, 2),
    @PremiumsRemarks        nvarchar(500),
    @UserId                 bigint
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @EffectiveDate > @TerminationDate
        THROW 50001, N'CustomSQLException: EffectiveDate must not be later than TerminationDate', 1;

    DECLARE @PolicyNumber bigint = NEXT VALUE FOR [Transaction].[PartnerPolicyNumberSequence];
    DECLARE @CocSequence bigint = NEXT VALUE FOR [Transaction].[CocNumberSequence];
    DECLARE @Id bigint;

    BEGIN TRANSACTION;

    INSERT INTO [Transaction].[PartnerPolicy]
    (
        [ReferenceNumber], [CocNumber], [PartnersId], [PlatformsId], [IssueStatus],
        [PolicyBookingStatusId], [CocStatusId], [PaymentStatusId], [ClaimsStatusId],
        [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId],
        [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId],
        [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks],
        [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes],
        [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks],
        [CreatedBy], [ModifiedBy]
    )
    VALUES
    (
        [Transaction].[FormatReferenceNumber](2, @PolicyNumber), [Transaction].[FormatCocNumber](@CocSequence),
        @PartnersId, @PlatformsId, 1,
        @PolicyBookingStatusId, @CocStatusId, 2, @ClaimsStatusId,
        @AgentsId, @SubAgentsId, @ApproversId, @PromoManagersId, @SalesManagersId, @PromoOfficersId,
        @ProductsId, @ProvidersId, @DistributionChannelId, @PaymentOptionId,
        @ProviderPolicyNo, @EndorsementNo, @TerminationDate, @EffectiveDate, @IssueDate, @Remarks,
        ISNULL(@BasicPremium, 0), ISNULL(@BasicPremiumCommission, 0), ISNULL(@DJDPatricioMarkup, 0), ISNULL(@PartnerMarkup, 0), ISNULL(@Discount, 0), ISNULL(@Taxes, 0),
        ISNULL(@DST, 0), ISNULL(@VAT, 0), ISNULL(@LGT, 0), ISNULL(@PT, 0), ISNULL(@FST, 0), ISNULL(@NotarialFee, 0), ISNULL(@Others, 0), @PremiumsRemarks,
        @UserId, @UserId
    );

    SET @Id = CAST(SCOPE_IDENTITY() AS bigint);
    EXEC [Transaction].[SetPolicyPaymentStatus] @PolicyTypeId = 2, @PolicyId = @Id, @UserId = @UserId;

    COMMIT TRANSACTION;

    SELECT @Id AS [Id];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[PostGroupPolicy]
    @PartnersId             bigint,
    @PlatformsId            bigint,
    @PolicyBookingStatusId  bigint,
    @CocStatusId            bigint,
    @ClaimsStatusId         bigint,
    @AgentsId               bigint,
    @SubAgentsId            bigint,
    @ApproversId            bigint,
    @PromoManagersId        bigint,
    @SalesManagersId        bigint,
    @PromoOfficersId        bigint,
    @ProductsId             bigint,
    @ProvidersId            bigint,
    @DistributionChannelId  bigint,
    @PaymentOptionId        bigint,
    @AccountTypeId          bigint,
    @BranchCode             nvarchar(5),
    @BranchName             nvarchar(6),
    @ProviderPolicyNo       nvarchar(50),
    @EndorsementNo          nvarchar(50),
    @TerminationDate        date,
    @EffectiveDate          date,
    @IssueDate              date,
    @Remarks                nvarchar(500),
    @BasicPremium           decimal(18, 2),
    @BasicPremiumCommission decimal(18, 2),
    @DJDPatricioMarkup      decimal(18, 2),
    @PartnerMarkup          decimal(18, 2),
    @Discount               decimal(18, 2),
    @Taxes                  decimal(18, 2),
    @DST                    decimal(18, 2),
    @VAT                    decimal(18, 2),
    @LGT                    decimal(18, 2),
    @PT                     decimal(18, 2),
    @FST                    decimal(18, 2),
    @NotarialFee            decimal(18, 2),
    @Others                 decimal(18, 2),
    @PremiumsRemarks        nvarchar(500),
    @UserId                 bigint
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @EffectiveDate > @TerminationDate
        THROW 50001, N'CustomSQLException: EffectiveDate must not be later than TerminationDate', 1;

    DECLARE @PolicyNumber bigint = NEXT VALUE FOR [Transaction].[GroupPolicyNumberSequence];
    DECLARE @CocSequence bigint = NEXT VALUE FOR [Transaction].[CocNumberSequence];
    DECLARE @Id bigint;

    BEGIN TRANSACTION;

    INSERT INTO [Transaction].[GroupPolicy]
    (
        [ReferenceNumber], [CocNumber], [PartnersId], [PlatformsId], [IssueStatus],
        [PolicyBookingStatusId], [CocStatusId], [PaymentStatusId], [ClaimsStatusId],
        [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId],
        [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId], [AccountTypeId], [BranchCode], [BranchName],
        [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks],
        [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes],
        [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks],
        [CreatedBy], [ModifiedBy]
    )
    VALUES
    (
        [Transaction].[FormatReferenceNumber](3, @PolicyNumber), [Transaction].[FormatCocNumber](@CocSequence),
        @PartnersId, @PlatformsId, 1,
        @PolicyBookingStatusId, @CocStatusId, 2, @ClaimsStatusId,
        @AgentsId, @SubAgentsId, @ApproversId, @PromoManagersId, @SalesManagersId, @PromoOfficersId,
        @ProductsId, @ProvidersId, @DistributionChannelId, @PaymentOptionId, @AccountTypeId, @BranchCode, @BranchName,
        @ProviderPolicyNo, @EndorsementNo, @TerminationDate, @EffectiveDate, @IssueDate, @Remarks,
        ISNULL(@BasicPremium, 0), ISNULL(@BasicPremiumCommission, 0), ISNULL(@DJDPatricioMarkup, 0), ISNULL(@PartnerMarkup, 0), ISNULL(@Discount, 0), ISNULL(@Taxes, 0),
        ISNULL(@DST, 0), ISNULL(@VAT, 0), ISNULL(@LGT, 0), ISNULL(@PT, 0), ISNULL(@FST, 0), ISNULL(@NotarialFee, 0), ISNULL(@Others, 0), @PremiumsRemarks,
        @UserId, @UserId
    );

    SET @Id = CAST(SCOPE_IDENTITY() AS bigint);
    EXEC [Transaction].[SetPolicyPaymentStatus] @PolicyTypeId = 3, @PolicyId = @Id, @UserId = @UserId;

    COMMIT TRANSACTION;

    SELECT @Id AS [Id];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[PostPolicyBeneficiary]
    @PolicyId      bigint,
    @PolicyTypeId  bigint,
    @FirstName     nvarchar(60),
    @MiddleName    nvarchar(60),
    @LastName      nvarchar(60),
    @Suffix        nvarchar(10),
    @EmailAddress  nvarchar(100),
    @ContactNumber nvarchar(13),
    @DateOfBirth   date,
    @Relationship  bigint,
    @UserId        bigint
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [Transaction].[PolicyView] AS p WHERE p.[PolicyTypeId] = @PolicyTypeId AND p.[PolicyId] = @PolicyId AND p.[IsDeleted] = 0)
        THROW 50004, N'CustomSQLException: Policy not found', 1;

    INSERT INTO [Transaction].[PolicyBeneficiary]
        ([PolicyId], [PolicyTypeId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Relationship], [CreatedBy], [ModifiedBy])
    VALUES
        (@PolicyId, @PolicyTypeId, @FirstName, @MiddleName, @LastName, @Suffix, @EmailAddress, @ContactNumber, @DateOfBirth, @Relationship, @UserId, @UserId);

    SELECT CAST(SCOPE_IDENTITY() AS bigint) AS [Id];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[PostPolicyBenefits]
    @PolicyId                bigint,
    @PolicyTypeId            bigint,
    @BenefitsId              bigint,
    @CoverageAmount          decimal(18, 2),
    @PremiumAmount           decimal(18, 2),
    @PremiumCommissionAmount decimal(18, 2),
    @UserId                  bigint
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [Transaction].[PolicyView] AS p WHERE p.[PolicyTypeId] = @PolicyTypeId AND p.[PolicyId] = @PolicyId AND p.[IsDeleted] = 0)
        THROW 50004, N'CustomSQLException: Policy not found', 1;

    DECLARE @Id bigint;

    BEGIN TRANSACTION;

    INSERT INTO [Transaction].[PolicyBenefits]
        ([PolicyId], [PolicyTypeId], [BenefitsId], [CoverageAmount], [PremiumAmount], [PremiumCommissionAmount], [CreatedBy], [ModifiedBy])
    VALUES
        (@PolicyId, @PolicyTypeId, @BenefitsId, ISNULL(@CoverageAmount, 0), ISNULL(@PremiumAmount, 0), ISNULL(@PremiumCommissionAmount, 0), @UserId, @UserId);

    SET @Id = CAST(SCOPE_IDENTITY() AS bigint);
    EXEC [Transaction].[SetPolicyPaymentStatus] @PolicyTypeId = @PolicyTypeId, @PolicyId = @PolicyId, @UserId = @UserId;

    COMMIT TRANSACTION;

    SELECT @Id AS [Id];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[PostPolicyDeductibles]
    @PolicyId      bigint,
    @PolicyTypeId  bigint,
    @DeductiblesId bigint,
    @Amount        decimal(18, 2),
    @UserId        bigint
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [Transaction].[PolicyView] AS p WHERE p.[PolicyTypeId] = @PolicyTypeId AND p.[PolicyId] = @PolicyId AND p.[IsDeleted] = 0)
        THROW 50004, N'CustomSQLException: Policy not found', 1;

    INSERT INTO [Transaction].[PolicyDeductibles]
        ([PolicyId], [PolicyTypeId], [DeductiblesId], [Amount], [CreatedBy], [ModifiedBy])
    VALUES
        (@PolicyId, @PolicyTypeId, @DeductiblesId, ISNULL(@Amount, 0), @UserId, @UserId);

    SELECT CAST(SCOPE_IDENTITY() AS bigint) AS [Id];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[PostPolicyPayments]
    @PolicyId             bigint,
    @PolicyTypeId         bigint,
    @Amount               decimal(18, 2),
    @TransactionDateTime  datetime2(7),
    @TransactionCheckNo   nvarchar(50),
    @TransactionOrigin    nvarchar(50),
    @NotificationDateTime datetime2(7),
    @PaymentMethod        bigint,
    @Notes                nvarchar(500),
    @UserId               bigint
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [Transaction].[PolicyView] AS p WHERE p.[PolicyTypeId] = @PolicyTypeId AND p.[PolicyId] = @PolicyId AND p.[IsDeleted] = 0)
        THROW 50004, N'CustomSQLException: Policy not found', 1;

    DECLARE @Id bigint;

    BEGIN TRANSACTION;

    INSERT INTO [Transaction].[PolicyPayments]
        ([PolicyId], [PolicyTypeId], [Amount], [TransactionDateTime], [TransactionCheckNo], [TransactionOrigin], [NotificationDateTime], [PaymentMethod], [Notes], [CreatedBy], [ModifiedBy])
    VALUES
        (@PolicyId, @PolicyTypeId, @Amount, @TransactionDateTime, @TransactionCheckNo, @TransactionOrigin, @NotificationDateTime, @PaymentMethod, @Notes, @UserId, @UserId);

    SET @Id = CAST(SCOPE_IDENTITY() AS bigint);
    EXEC [Transaction].[SetPolicyPaymentStatus] @PolicyTypeId = @PolicyTypeId, @PolicyId = @PolicyId, @UserId = @UserId;

    COMMIT TRANSACTION;

    SELECT @Id AS [Id];
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[PostAttachments]
    @ReferenceId      bigint,
    @AttachmentTypeId bigint,
    @ContentType      nvarchar(100),
    @FileName         nvarchar(255),
    @Attachment       varbinary(max),
    @UserId           bigint
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS
    (
        SELECT 1 FROM [Transaction].[IndividualPolicy] WHERE @AttachmentTypeId = 1 AND [Id] = @ReferenceId AND [IsDeleted] = 0
        UNION ALL
        SELECT 1 FROM [Transaction].[PartnerPolicy] WHERE @AttachmentTypeId = 2 AND [Id] = @ReferenceId AND [IsDeleted] = 0
        UNION ALL
        SELECT 1 FROM [Transaction].[GroupPolicy] WHERE @AttachmentTypeId IN (3, 4) AND [Id] = @ReferenceId AND [IsDeleted] = 0
        UNION ALL
        SELECT 1 FROM [Transaction].[PolicyPayments] WHERE @AttachmentTypeId = 5 AND [Id] = @ReferenceId AND [IsDeleted] = 0
    )
        THROW 50005, N'CustomSQLException: Referenced record not found for the attachment type', 1;

    INSERT INTO [Transaction].[Attachments]
        ([ReferenceId], [AttachmentTypeId], [ContentType], [FileName], [Attachment], [CreatedBy], [ModifiedBy])
    VALUES
        (@ReferenceId, @AttachmentTypeId, @ContentType, @FileName, ISNULL(@Attachment, 0x), @UserId, @UserId);

    SELECT CAST(SCOPE_IDENTITY() AS bigint) AS [Id];
END;
GO

/* ---------- Transaction: Put (IsDeleted = 1 is the soft delete sent by the Delete endpoints) ---------- */

CREATE OR ALTER PROCEDURE [Transaction].[PutIndividualPolicy]
    @Id                     bigint,
    @AgentsId               bigint,
    @SubAgentsId            bigint,
    @ApproversId            bigint,
    @PromoManagersId        bigint,
    @SalesManagersId        bigint,
    @PromoOfficersId        bigint,
    @Remarks                nvarchar(500),
    @BasicPremium           decimal(18, 2),
    @BasicPremiumCommission decimal(18, 2),
    @DJDPatricioMarkup      decimal(18, 2),
    @PartnerMarkup          decimal(18, 2),
    @Discount               decimal(18, 2),
    @Taxes                  decimal(18, 2),
    @DST                    decimal(18, 2),
    @VAT                    decimal(18, 2),
    @LGT                    decimal(18, 2),
    @PT                     decimal(18, 2),
    @FST                    decimal(18, 2),
    @NotarialFee            decimal(18, 2),
    @Others                 decimal(18, 2),
    @PremiumsRemarks        nvarchar(500),
    @IssueStatus            bit,
    @PolicyBookingStatusId  bigint,
    @CocStatusId            bigint,
    @ClaimsStatusId         bigint,
    @UserId                 bigint,
    @IsDeleted              bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [Transaction].[IndividualPolicy] WHERE [Id] = @Id AND [IsDeleted] = 0)
        THROW 50004, N'CustomSQLException: Policy not found', 1;

    IF ISNULL(@IsDeleted, 0) = 1
    BEGIN
        UPDATE [Transaction].[IndividualPolicy]
        SET [IsDeleted] = 1, [DeletedBy] = @UserId, [DeletedDateTime] = SYSUTCDATETIME(), [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
        WHERE [Id] = @Id;
        RETURN;
    END;

    BEGIN TRANSACTION;

    UPDATE [Transaction].[IndividualPolicy]
    SET [AgentsId] = @AgentsId, [SubAgentsId] = @SubAgentsId, [ApproversId] = @ApproversId,
        [PromoManagersId] = @PromoManagersId, [SalesManagersId] = @SalesManagersId, [PromoOfficersId] = @PromoOfficersId,
        [Remarks] = @Remarks,
        [BasicPremium] = ISNULL(@BasicPremium, 0), [BasicPremiumCommission] = ISNULL(@BasicPremiumCommission, 0),
        [DJDPatricioMarkup] = ISNULL(@DJDPatricioMarkup, 0), [PartnerMarkup] = ISNULL(@PartnerMarkup, 0), [Discount] = ISNULL(@Discount, 0),
        [Taxes] = ISNULL(@Taxes, 0), [DST] = ISNULL(@DST, 0), [VAT] = ISNULL(@VAT, 0), [LGT] = ISNULL(@LGT, 0), [PT] = ISNULL(@PT, 0),
        [FST] = ISNULL(@FST, 0), [NotarialFee] = ISNULL(@NotarialFee, 0), [Others] = ISNULL(@Others, 0), [PremiumsRemarks] = @PremiumsRemarks,
        [IssueStatus] = ISNULL(@IssueStatus, [IssueStatus]),
        [PolicyBookingStatusId] = ISNULL(@PolicyBookingStatusId, [PolicyBookingStatusId]),
        [CocStatusId] = ISNULL(@CocStatusId, [CocStatusId]),
        [ClaimsStatusId] = ISNULL(@ClaimsStatusId, [ClaimsStatusId]),
        [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
    WHERE [Id] = @Id;

    EXEC [Transaction].[SetPolicyPaymentStatus] @PolicyTypeId = 1, @PolicyId = @Id, @UserId = @UserId;

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[PutPartnerPolicy]
    @Id                     bigint,
    @AgentsId               bigint,
    @SubAgentsId            bigint,
    @ApproversId            bigint,
    @PromoManagersId        bigint,
    @SalesManagersId        bigint,
    @PromoOfficersId        bigint,
    @Remarks                nvarchar(500),
    @BasicPremium           decimal(18, 2),
    @BasicPremiumCommission decimal(18, 2),
    @DJDPatricioMarkup      decimal(18, 2),
    @PartnerMarkup          decimal(18, 2),
    @Discount               decimal(18, 2),
    @Taxes                  decimal(18, 2),
    @DST                    decimal(18, 2),
    @VAT                    decimal(18, 2),
    @LGT                    decimal(18, 2),
    @PT                     decimal(18, 2),
    @FST                    decimal(18, 2),
    @NotarialFee            decimal(18, 2),
    @Others                 decimal(18, 2),
    @PremiumsRemarks        nvarchar(500),
    @IssueStatus            bit,
    @PolicyBookingStatusId  bigint,
    @CocStatusId            bigint,
    @ClaimsStatusId         bigint,
    @UserId                 bigint,
    @IsDeleted              bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [Transaction].[PartnerPolicy] WHERE [Id] = @Id AND [IsDeleted] = 0)
        THROW 50004, N'CustomSQLException: Policy not found', 1;

    IF ISNULL(@IsDeleted, 0) = 1
    BEGIN
        UPDATE [Transaction].[PartnerPolicy]
        SET [IsDeleted] = 1, [DeletedBy] = @UserId, [DeletedDateTime] = SYSUTCDATETIME(), [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
        WHERE [Id] = @Id;
        RETURN;
    END;

    BEGIN TRANSACTION;

    UPDATE [Transaction].[PartnerPolicy]
    SET [AgentsId] = @AgentsId, [SubAgentsId] = @SubAgentsId, [ApproversId] = @ApproversId,
        [PromoManagersId] = @PromoManagersId, [SalesManagersId] = @SalesManagersId, [PromoOfficersId] = @PromoOfficersId,
        [Remarks] = @Remarks,
        [BasicPremium] = ISNULL(@BasicPremium, 0), [BasicPremiumCommission] = ISNULL(@BasicPremiumCommission, 0),
        [DJDPatricioMarkup] = ISNULL(@DJDPatricioMarkup, 0), [PartnerMarkup] = ISNULL(@PartnerMarkup, 0), [Discount] = ISNULL(@Discount, 0),
        [Taxes] = ISNULL(@Taxes, 0), [DST] = ISNULL(@DST, 0), [VAT] = ISNULL(@VAT, 0), [LGT] = ISNULL(@LGT, 0), [PT] = ISNULL(@PT, 0),
        [FST] = ISNULL(@FST, 0), [NotarialFee] = ISNULL(@NotarialFee, 0), [Others] = ISNULL(@Others, 0), [PremiumsRemarks] = @PremiumsRemarks,
        [IssueStatus] = ISNULL(@IssueStatus, [IssueStatus]),
        [PolicyBookingStatusId] = ISNULL(@PolicyBookingStatusId, [PolicyBookingStatusId]),
        [CocStatusId] = ISNULL(@CocStatusId, [CocStatusId]),
        [ClaimsStatusId] = ISNULL(@ClaimsStatusId, [ClaimsStatusId]),
        [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
    WHERE [Id] = @Id;

    EXEC [Transaction].[SetPolicyPaymentStatus] @PolicyTypeId = 2, @PolicyId = @Id, @UserId = @UserId;

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[PutGroupPolicy]
    @Id                     bigint,
    @AgentsId               bigint,
    @SubAgentsId            bigint,
    @ApproversId            bigint,
    @PromoManagersId        bigint,
    @SalesManagersId        bigint,
    @PromoOfficersId        bigint,
    @Remarks                nvarchar(500),
    @BasicPremium           decimal(18, 2),
    @BasicPremiumCommission decimal(18, 2),
    @DJDPatricioMarkup      decimal(18, 2),
    @PartnerMarkup          decimal(18, 2),
    @Discount               decimal(18, 2),
    @Taxes                  decimal(18, 2),
    @DST                    decimal(18, 2),
    @VAT                    decimal(18, 2),
    @LGT                    decimal(18, 2),
    @PT                     decimal(18, 2),
    @FST                    decimal(18, 2),
    @NotarialFee            decimal(18, 2),
    @Others                 decimal(18, 2),
    @PremiumsRemarks        nvarchar(500),
    @IssueStatus            bit,
    @PolicyBookingStatusId  bigint,
    @CocStatusId            bigint,
    @ClaimsStatusId         bigint,
    @UserId                 bigint,
    @IsDeleted              bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [Transaction].[GroupPolicy] WHERE [Id] = @Id AND [IsDeleted] = 0)
        THROW 50004, N'CustomSQLException: Policy not found', 1;

    IF ISNULL(@IsDeleted, 0) = 1
    BEGIN
        UPDATE [Transaction].[GroupPolicy]
        SET [IsDeleted] = 1, [DeletedBy] = @UserId, [DeletedDateTime] = SYSUTCDATETIME(), [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
        WHERE [Id] = @Id;
        RETURN;
    END;

    BEGIN TRANSACTION;

    UPDATE [Transaction].[GroupPolicy]
    SET [AgentsId] = @AgentsId, [SubAgentsId] = @SubAgentsId, [ApproversId] = @ApproversId,
        [PromoManagersId] = @PromoManagersId, [SalesManagersId] = @SalesManagersId, [PromoOfficersId] = @PromoOfficersId,
        [Remarks] = @Remarks,
        [BasicPremium] = ISNULL(@BasicPremium, 0), [BasicPremiumCommission] = ISNULL(@BasicPremiumCommission, 0),
        [DJDPatricioMarkup] = ISNULL(@DJDPatricioMarkup, 0), [PartnerMarkup] = ISNULL(@PartnerMarkup, 0), [Discount] = ISNULL(@Discount, 0),
        [Taxes] = ISNULL(@Taxes, 0), [DST] = ISNULL(@DST, 0), [VAT] = ISNULL(@VAT, 0), [LGT] = ISNULL(@LGT, 0), [PT] = ISNULL(@PT, 0),
        [FST] = ISNULL(@FST, 0), [NotarialFee] = ISNULL(@NotarialFee, 0), [Others] = ISNULL(@Others, 0), [PremiumsRemarks] = @PremiumsRemarks,
        [IssueStatus] = ISNULL(@IssueStatus, [IssueStatus]),
        [PolicyBookingStatusId] = ISNULL(@PolicyBookingStatusId, [PolicyBookingStatusId]),
        [CocStatusId] = ISNULL(@CocStatusId, [CocStatusId]),
        [ClaimsStatusId] = ISNULL(@ClaimsStatusId, [ClaimsStatusId]),
        [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
    WHERE [Id] = @Id;

    EXEC [Transaction].[SetPolicyPaymentStatus] @PolicyTypeId = 3, @PolicyId = @Id, @UserId = @UserId;

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[PutPolicyBeneficiary]
    @Id            bigint,
    @FirstName     nvarchar(60),
    @MiddleName    nvarchar(60),
    @LastName      nvarchar(60),
    @Suffix        nvarchar(10),
    @EmailAddress  nvarchar(100),
    @ContactNumber nvarchar(13),
    @DateOfBirth   date,
    @Relationship  bigint,
    @UserId        bigint,
    @IsDeleted     bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [Transaction].[PolicyBeneficiary] WHERE [Id] = @Id AND [IsDeleted] = 0)
        THROW 50006, N'CustomSQLException: Beneficiary not found', 1;

    IF ISNULL(@IsDeleted, 0) = 1
    BEGIN
        UPDATE [Transaction].[PolicyBeneficiary]
        SET [IsDeleted] = 1, [DeletedBy] = @UserId, [DeletedDateTime] = SYSUTCDATETIME(), [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
        WHERE [Id] = @Id;
        RETURN;
    END;

    UPDATE [Transaction].[PolicyBeneficiary]
    SET [FirstName] = @FirstName, [MiddleName] = @MiddleName, [LastName] = @LastName, [Suffix] = @Suffix,
        [EmailAddress] = @EmailAddress, [ContactNumber] = @ContactNumber, [DateOfBirth] = @DateOfBirth, [Relationship] = @Relationship,
        [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
    WHERE [Id] = @Id;
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[PutPolicyPayments]
    @Id                   bigint,
    @Amount               decimal(18, 2),
    @TransactionDateTime  datetime2(7),
    @TransactionCheckNo   nvarchar(50),
    @TransactionOrigin    nvarchar(50),
    @NotificationDateTime datetime2(7),
    @PaymentMethod        bigint,
    @Notes                nvarchar(500),
    @UserId               bigint,
    @IsDeleted            bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @PolicyId bigint, @PolicyTypeId bigint;

    SELECT @PolicyId = [PolicyId], @PolicyTypeId = [PolicyTypeId]
    FROM [Transaction].[PolicyPayments]
    WHERE [Id] = @Id AND [IsDeleted] = 0;

    IF @PolicyId IS NULL
        THROW 50007, N'CustomSQLException: Payment not found', 1;

    BEGIN TRANSACTION;

    IF ISNULL(@IsDeleted, 0) = 1
        UPDATE [Transaction].[PolicyPayments]
        SET [IsDeleted] = 1, [DeletedBy] = @UserId, [DeletedDateTime] = SYSUTCDATETIME(), [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
        WHERE [Id] = @Id;
    ELSE
        UPDATE [Transaction].[PolicyPayments]
        SET [Amount] = @Amount, [TransactionDateTime] = @TransactionDateTime, [TransactionCheckNo] = @TransactionCheckNo,
            [TransactionOrigin] = @TransactionOrigin, [NotificationDateTime] = @NotificationDateTime, [PaymentMethod] = @PaymentMethod,
            [Notes] = @Notes, [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
        WHERE [Id] = @Id;

    EXEC [Transaction].[SetPolicyPaymentStatus] @PolicyTypeId = @PolicyTypeId, @PolicyId = @PolicyId, @UserId = @UserId;

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [Transaction].[PutAttachments]
    @Id          bigint,
    @ContentType nvarchar(100),
    @FileName    nvarchar(255),
    @Attachment  varbinary(max),
    @UserId      bigint,
    @IsDeleted   bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [Transaction].[Attachments] WHERE [Id] = @Id AND [IsDeleted] = 0)
        THROW 50008, N'CustomSQLException: Attachment not found', 1;

    IF ISNULL(@IsDeleted, 0) = 1
    BEGIN
        UPDATE [Transaction].[Attachments]
        SET [IsDeleted] = 1, [DeletedBy] = @UserId, [DeletedDateTime] = SYSUTCDATETIME(), [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
        WHERE [Id] = @Id;
        RETURN;
    END;

    UPDATE [Transaction].[Attachments]
    SET [ContentType] = @ContentType, [FileName] = @FileName, [Attachment] = ISNULL(@Attachment, 0x),
        [ModifiedBy] = @UserId, [ModifiedDateTime] = SYSUTCDATETIME()
    WHERE [Id] = @Id;
END;
GO

/* ---------- dbo: dashboard ---------- */

/* One row per product with its bookings, premiums and payments. Trend compares bookings in the last 30 days with the 30 days before. */
CREATE OR ALTER PROCEDURE [dbo].[GetProductSummary]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now datetime2(7) = SYSUTCDATETIME();

    WITH [Bookings] AS
    (
        SELECT
            pv.[ProductsId],
            COUNT(*) AS [TotalBookings],
            SUM(pv.[TotalPremium]) AS [TotalPremiums],
            SUM(pv.[TotalPaid]) AS [TotalPayments],
            MAX(pv.[CreatedDateTime]) AS [LastTransaction],
            SUM(CASE WHEN pv.[CreatedDateTime] >= DATEADD(DAY, -30, @Now) THEN 1 ELSE 0 END) AS [RecentBookings],
            SUM(CASE WHEN pv.[CreatedDateTime] >= DATEADD(DAY, -60, @Now) AND pv.[CreatedDateTime] < DATEADD(DAY, -30, @Now) THEN 1 ELSE 0 END) AS [PreviousBookings]
        FROM [Transaction].[PolicyView] AS pv
        WHERE pv.[IsDeleted] = 0
        GROUP BY pv.[ProductsId]
    )
    SELECT
        ISNULL(pc.[Description], pc.[Name]) AS [Category],
        p.[Name] AS [ProductName],
        p.[Code] AS [ProductCode],
        ISNULL(b.[TotalBookings], 0) AS [TotalBookings],
        CAST(ISNULL(b.[TotalPremiums], 0) AS decimal(18, 2)) AS [TotalPremiums],
        CAST(ISNULL(b.[TotalPayments], 0) AS decimal(18, 2)) AS [TotalPayments],
        b.[LastTransaction],
        CASE
            WHEN ISNULL(b.[RecentBookings], 0) > ISNULL(b.[PreviousBookings], 0) THEN N'UP'
            WHEN ISNULL(b.[RecentBookings], 0) < ISNULL(b.[PreviousBookings], 0) THEN N'DOWN'
            ELSE N'MIDDLE'
        END AS [Trend]
    FROM [Reference].[Products] AS p
    INNER JOIN [Reference].[ProductCategory] AS pc ON pc.[Id] = p.[ProductCategoryId]
    LEFT JOIN [Bookings] AS b ON b.[ProductsId] = p.[Id]
    WHERE p.[IsDeleted] = 0
    ORDER BY ISNULL(pc.[Description], pc.[Name]), p.[Name];
END;
GO

/* Bookings per booking status per period, every period present even when empty. */
CREATE OR ALTER PROCEDURE [dbo].[GetTotalBookingPerStatus]
    @timePeriodOption int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Today date = CAST(SYSUTCDATETIME() AS date);

    SELECT
        CAST(ap.[ActivityDate] AS datetime2(7)) AS [ActivityDate],
        SUM(CASE WHEN pv.[PolicyBookingStatusId] = 1 THEN 1 ELSE 0 END) AS [Approved],
        SUM(CASE WHEN pv.[PolicyBookingStatusId] = 2 THEN 1 ELSE 0 END) AS [Disapproved],
        SUM(CASE WHEN pv.[PolicyBookingStatusId] = 3 THEN 1 ELSE 0 END) AS [Pending],
        SUM(CASE WHEN pv.[PolicyBookingStatusId] = 4 THEN 1 ELSE 0 END) AS [Declined],
        SUM(CASE WHEN pv.[PolicyBookingStatusId] = 5 THEN 1 ELSE 0 END) AS [Quoted],
        SUM(CASE WHEN pv.[PolicyBookingStatusId] = 6 THEN 1 ELSE 0 END) AS [Draft],
        SUM(CASE WHEN pv.[PolicyBookingStatusId] = 7 THEN 1 ELSE 0 END) AS [AutoApproved],
        COUNT(pv.[PolicyId]) AS [TotalCount]
    FROM [dbo].[GetActivityPeriods](ISNULL(@timePeriodOption, 4), @Today) AS ap
    LEFT JOIN
    (
        SELECT k.[PolicyId], k.[PolicyBookingStatusId], k.[CreatedDateTime]
        FROM
        (
            SELECT p.[Id] AS [PolicyId], p.[PolicyBookingStatusId], p.[CreatedDateTime], p.[IsDeleted] FROM [Transaction].[IndividualPolicy] AS p
            UNION ALL
            SELECT p.[Id], p.[PolicyBookingStatusId], p.[CreatedDateTime], p.[IsDeleted] FROM [Transaction].[PartnerPolicy] AS p
            UNION ALL
            SELECT p.[Id], p.[PolicyBookingStatusId], p.[CreatedDateTime], p.[IsDeleted] FROM [Transaction].[GroupPolicy] AS p
        ) AS k
        WHERE k.[IsDeleted] = 0
    ) AS pv
        ON pv.[CreatedDateTime] >= CAST(ap.[ActivityDate] AS datetime2(7))
       AND pv.[CreatedDateTime] < CAST(ap.[PeriodEnd] AS datetime2(7))
    GROUP BY ap.[ActivityDate]
    ORDER BY ap.[ActivityDate];
END;
GO

/* Current calendar year (UTC) against the previous one for revenue (payments received), bookings, new customers and new partners. */
CREATE OR ALTER PROCEDURE [dbo].[GetSummaryYearToYear]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentYear int = YEAR(SYSUTCDATETIME());
    DECLARE @PreviousYear int = @CurrentYear - 1;

    WITH [Metrics] AS
    (
        SELECT 1 AS [Id], N'Revenue' AS [MetricName],
               CAST(ISNULL(SUM(CASE WHEN YEAR(pp.[TransactionDateTime]) = @CurrentYear THEN pp.[Amount] END), 0) AS decimal(18, 2)) AS [CurrentYearValue],
               CAST(ISNULL(SUM(CASE WHEN YEAR(pp.[TransactionDateTime]) = @PreviousYear THEN pp.[Amount] END), 0) AS decimal(18, 2)) AS [PreviousYearValue]
        FROM [Transaction].[PolicyPayments] AS pp
        WHERE pp.[IsDeleted] = 0
        UNION ALL
        SELECT 2, N'Bookings',
               CAST(SUM(CASE WHEN YEAR(k.[CreatedDateTime]) = @CurrentYear THEN 1 ELSE 0 END) AS decimal(18, 2)),
               CAST(SUM(CASE WHEN YEAR(k.[CreatedDateTime]) = @PreviousYear THEN 1 ELSE 0 END) AS decimal(18, 2))
        FROM
        (
            SELECT [CreatedDateTime] FROM [Transaction].[IndividualPolicy] WHERE [IsDeleted] = 0
            UNION ALL
            SELECT [CreatedDateTime] FROM [Transaction].[PartnerPolicy] WHERE [IsDeleted] = 0
            UNION ALL
            SELECT [CreatedDateTime] FROM [Transaction].[GroupPolicy] WHERE [IsDeleted] = 0
        ) AS k
        UNION ALL
        SELECT 3, N'Customers',
               CAST(SUM(CASE WHEN YEAR(c.[CreatedDateTime]) = @CurrentYear THEN 1 ELSE 0 END) AS decimal(18, 2)),
               CAST(SUM(CASE WHEN YEAR(c.[CreatedDateTime]) = @PreviousYear THEN 1 ELSE 0 END) AS decimal(18, 2))
        FROM [Reference].[Clients] AS c
        WHERE c.[IsDeleted] = 0
        UNION ALL
        SELECT 4, N'Partners',
               CAST(SUM(CASE WHEN YEAR(p.[CreatedDateTime]) = @CurrentYear THEN 1 ELSE 0 END) AS decimal(18, 2)),
               CAST(SUM(CASE WHEN YEAR(p.[CreatedDateTime]) = @PreviousYear THEN 1 ELSE 0 END) AS decimal(18, 2))
        FROM [Reference].[Partners] AS p
        WHERE p.[IsDeleted] = 0
    )
    SELECT
        m.[Id],
        m.[MetricName],
        @CurrentYear AS [ReportingYear],
        ISNULL(m.[CurrentYearValue], 0) AS [CurrentYearValue],
        ISNULL(m.[PreviousYearValue], 0) AS [PreviousYearValue],
        CAST(CASE
            WHEN ISNULL(m.[PreviousYearValue], 0) = 0 THEN ISNULL(m.[CurrentYearValue], 0) * 100
            ELSE (ISNULL(m.[CurrentYearValue], 0) - m.[PreviousYearValue]) / m.[PreviousYearValue] * 100
        END AS decimal(18, 2)) AS [PercentageIncrease],
        CASE
            WHEN ISNULL(m.[CurrentYearValue], 0) > ISNULL(m.[PreviousYearValue], 0) THEN N'UP'
            WHEN ISNULL(m.[CurrentYearValue], 0) < ISNULL(m.[PreviousYearValue], 0) THEN N'DOWN'
            ELSE N'MIDDLE'
        END AS [Trend]
    FROM [Metrics] AS m
    ORDER BY m.[Id];
END;
GO

INSERT INTO [Static].[AddressRegion] ([Id], [Name], [Code])
SELECT v.[Id], v.[Name], v.[Code]
FROM (VALUES
    (1, N'Asia', N'AS')
) AS v ([Id], [Name], [Code])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[AddressRegion] AS t WHERE t.[Id] = v.[Id]);
GO

INSERT INTO [Static].[AddressRegionDivision] ([Id], [AddressRegionId], [Name], [Code])
SELECT v.[Id], v.[AddressRegionId], v.[Name], v.[Code]
FROM (VALUES
    (1, 1, N'Southeast', N'SE')
) AS v ([Id], [AddressRegionId], [Name], [Code])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[AddressRegionDivision] AS t WHERE t.[Id] = v.[Id]);
GO

INSERT INTO [Static].[AddressCountry] ([Id], [AddressRegionDivisionId], [Name], [Code], [PhoneCode], [TopLevelDomain], [Currency], [CurrencyName], [Nationality])
SELECT v.[Id], v.[AddressRegionDivisionId], v.[Name], v.[Code], v.[PhoneCode], v.[TopLevelDomain], v.[Currency], v.[CurrencyName], v.[Nationality]
FROM (VALUES
    (1, 1, N'Philippines', N'PH', N'+63', N'.ph', N'PHP', N'Philippine peso', N'Filipino')
) AS v ([Id], [AddressRegionDivisionId], [Name], [Code], [PhoneCode], [TopLevelDomain], [Currency], [CurrencyName], [Nationality])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[AddressCountry] AS t WHERE t.[Id] = v.[Id]);
GO

INSERT INTO [Static].[AddressCountryDivision] ([Id], [AddressCountryId], [Name], [Acronym], [Code])
SELECT v.[Id], v.[AddressCountryId], v.[Name], v.[Acronym], v.[Code]
FROM (VALUES
    (1, 1, N'National Capital Region', N'NCR', N'00'),
    (2, 1, N'Cordillera Administrative Region', N'CAR', N'15'),
    (3, 1, N'Ilocos Region', N'Region I', N'01'),
    (4, 1, N'Cagayan Valley', N'Region II', N'02'),
    (5, 1, N'Central Luzon', N'Region III', N'03'),
    (6, 1, N'CALABARZON', N'Region IV-A', N'40'),
    (7, 1, N'MIMAROPA', N'Region IV-B', N'41'),
    (8, 1, N'Bicol Region', N'Region V', N'05'),
    (9, 1, N'Western Visayas', N'Region VI', N'06'),
    (10, 1, N'Central Visayas', N'Region VII', N'07'),
    (11, 1, N'Eastern Visayas', N'Region VIII', N'08'),
    (12, 1, N'Zamboanga Peninsula', N'Region IX', N'09'),
    (13, 1, N'Northern Mindanao', N'Region X', N'10'),
    (14, 1, N'Davao Region', N'Region XI', N'11'),
    (15, 1, N'SOCCSKSARGEN', N'Region XII', N'12'),
    (16, 1, N'CARAGA', N'Region XIII', N'13'),
    (17, 1, N'Autonomous Region in Muslim Mindanao', N'ARMM', N'14')
) AS v ([Id], [AddressCountryId], [Name], [Acronym], [Code])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[AddressCountryDivision] AS t WHERE t.[Id] = v.[Id]);
GO

INSERT INTO [Static].[AddressState] ([Id], [AddressCountryDivisionId], [Name], [Code])
SELECT v.[Id], v.[AddressCountryDivisionId], v.[Name], v.[Code]
FROM (VALUES
    (1, 1, N'Metro Manila', N'0'),
    (2, 3, N'Ilocos Norte', N'0'),
    (3, 3, N'Ilocos Sur', N'0'),
    (4, 3, N'La Union', N'0'),
    (5, 3, N'Pangasinan', N'0'),
    (6, 4, N'Batanes', N'0'),
    (7, 4, N'Cagayan', N'0'),
    (8, 4, N'Isabela', N'0'),
    (9, 4, N'Nueva Vizcaya', N'0'),
    (10, 4, N'Quirino', N'0'),
    (11, 5, N'Bataan', N'0'),
    (12, 5, N'Bulacan', N'0'),
    (13, 5, N'Nueva Ecija', N'0'),
    (14, 5, N'Pampanga', N'0'),
    (15, 5, N'Tarlac', N'0'),
    (16, 5, N'Zambales', N'0'),
    (17, 5, N'Aurora', N'0'),
    (18, 6, N'Batangas', N'0'),
    (19, 6, N'Cavite', N'0'),
    (20, 6, N'Laguna', N'0'),
    (21, 6, N'Quezon', N'0'),
    (22, 6, N'Rizal', N'0'),
    (23, 7, N'Marinduque', N'0'),
    (24, 7, N'Occidental Mindoro', N'0'),
    (25, 7, N'Oriental Mindoro', N'0'),
    (26, 7, N'Palawan', N'0'),
    (27, 7, N'Romblon', N'0'),
    (28, 8, N'Albay', N'0'),
    (29, 8, N'Camarines Norte', N'0'),
    (30, 8, N'Camarines Sur', N'0'),
    (31, 8, N'Catanduanes', N'0'),
    (32, 8, N'Masbate', N'0'),
    (33, 8, N'Sorsogon', N'0'),
    (34, 9, N'Aklan', N'0'),
    (35, 9, N'Antique', N'0'),
    (36, 9, N'Capiz', N'0'),
    (37, 9, N'Iloilo', N'0'),
    (38, 9, N'Negros Occidental', N'0'),
    (39, 9, N'Guimaras', N'0'),
    (40, 10, N'Bohol', N'0'),
    (41, 10, N'Cebu', N'0'),
    (42, 10, N'Negros Oriental', N'0'),
    (43, 10, N'Siquijor', N'0'),
    (44, 11, N'Eastern Samar', N'0'),
    (45, 11, N'Leyte', N'0'),
    (46, 11, N'Northern Samar', N'0'),
    (47, 11, N'Samar', N'0'),
    (48, 11, N'Southern Leyte', N'0'),
    (49, 11, N'Biliran', N'0'),
    (50, 12, N'Zamboanga del Norte', N'0'),
    (51, 12, N'Zamboanga del Sur', N'0'),
    (52, 12, N'Zamboanga Sibugay', N'0'),
    (53, 13, N'Bukidnon', N'0'),
    (54, 13, N'Camiguin', N'0'),
    (55, 13, N'Lanao del Norte', N'0'),
    (56, 13, N'Misamis Occidental', N'0'),
    (57, 13, N'Misamis Oriental', N'0'),
    (58, 14, N'Davao del Norte', N'0'),
    (59, 14, N'Davao del Sur', N'0'),
    (60, 14, N'Davao Oriental', N'0'),
    (61, 14, N'Davao de Oro', N'0'),
    (62, 14, N'Davao Occidental', N'0'),
    (63, 15, N'Cotabato', N'0'),
    (64, 15, N'South Cotabato', N'0'),
    (65, 15, N'Sultan Kudarat', N'0'),
    (66, 15, N'Sarangani', N'0'),
    (67, 2, N'Abra', N'0'),
    (68, 2, N'Benguet', N'0'),
    (69, 2, N'Ifugao', N'0'),
    (70, 2, N'Kalinga', N'0'),
    (71, 2, N'Mountain Province', N'0'),
    (72, 2, N'Apayao', N'0'),
    (73, 17, N'Basilan', N'0'),
    (74, 17, N'Lanao del Sur', N'0'),
    (75, 17, N'Maguindanao', N'0'),
    (76, 17, N'Sulu', N'0'),
    (77, 17, N'Tawi-Tawi', N'0'),
    (78, 16, N'Agusan del Norte', N'0'),
    (79, 16, N'Agusan del Sur', N'0'),
    (80, 16, N'Surigao del Norte', N'0'),
    (81, 16, N'Surigao del Sur', N'0'),
    (82, 16, N'Dinagat Islands', N'0')
) AS v ([Id], [AddressCountryDivisionId], [Name], [Code])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[AddressState] AS t WHERE t.[Id] = v.[Id]);
GO

INSERT INTO [Static].[AddressCity] ([Id], [AddressStateId], [Name])
SELECT v.[Id], v.[AddressStateId], v.[Name]
FROM (VALUES
    (50, 3, N'Santiago'),
    (57, 3, N'Vigan City (Capital)'),
    (119, 5, N'Sual'),
    (142, 7, N'Claveria'),
    (144, 7, N'Gattaran'),
    (148, 7, N'Lasam'),
    (156, 7, N'Santa Teresita'),
    (160, 7, N'Tuguegarao City (Capital)'),
    (393, 19, N'Kawit'),
    (397, 19, N'Naic'),
    (432, 20, N'Santa Maria'),
    (451, 21, N'Lopez'),
    (491, 23, N'Boac (Capital)'),
    (526, 26, N'Balabac'),
    (558, 27, N'San Andres'),
    (570, 28, N'Libon'),
    (575, 28, N'Oas'),
    (616, 30, N'Nabua'),
    (640, 31, N'Viga'),
    (642, 32, N'Aroroy'),
    (648, 32, N'Claveria'),
    (658, 32, N'Placer'),
    (684, 34, N'Kalibo (Capital)'),
    (716, 36, N'Dumarao'),
    (746, 37, N'Dumangas'),
    (750, 37, N'Iloilo City (Capital)'),
    (789, 38, N'La Carlota City'),
    (794, 38, N'Pontevedra'),
    (819, 40, N'Buenavista'),
    (866, 41, N'Balamban'),
    (880, 41, N'Dalaguete'),
    (915, 42, N'Bais City'),
    (954, 44, N'Lawaan'),
    (963, 44, N'San Policarpo'),
    (995, 45, N'Ormoc City'),
    (1049, 47, N'Santa Rita'),
    (1067, 48, N'Malitbog'),
    (1073, 48, N'San Ricardo'),
    (1079, 49, N'Biliran'),
    (1081, 49, N'Caibiran'),
    (1126, 51, N'Pagadian City (Capital)'),
    (1131, 51, N'Tambulig'),
    (1190, 55, N'Sultan Naga Dimaporo'),
    (1218, 56, N'Panaon'),
    (1236, 57, N'Kinoguitan'),
    (1252, 58, N'Carmen'),
    (1261, 58, N'San Isidro'),
    (1280, 60, N'Manay'),
    (1307, 63, N'Matalam'),
    (1324, 64, N'Tampakan'),
    (1343, 66, N'Glan'),
    (1350, 1, N'Manila City (Capital)'),
    (1356, 1, N'Caloocan City'),
    (1364, 1, N'Pasay City'),
    (1373, 67, N'Dolores'),
    (1395, 68, N'Baguio City'),
    (1432, 71, N'Paracelis'),
    (1463, 74, N'Ganassi'),
    (1474, 74, N'Pagayawan'),
    (1487, 74, N'Buadiposo-Buntong'),
    (1505, 75, N'Parang'),
    (1538, 76, N'Old Panamao'),
    (1576, 79, N'Esperanza'),
    (1597, 80, N'Malimono'),
    (1611, 81, N'Bislig City')
) AS v ([Id], [AddressStateId], [Name])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[AddressCity] AS t WHERE t.[Id] = v.[Id]);
GO

INSERT INTO [Static].[AddressTown] ([Id], [AddressCityId], [Name], [Code])
SELECT v.[Id], v.[AddressCityId], v.[Name], v.[Code]
FROM (VALUES
    (1126, 50, N'Bulbulala', N'0'),
    (1304, 57, N'Cabaroan Laud', N'0'),
    (3081, 119, N'Macaycayawan', N'0'),
    (3625, 142, N'Cadcadir West', N'0'),
    (3681, 144, N'Guising', N'0'),
    (3814, 148, N'Cabatacan East', N'0'),
    (3962, 156, N'Villa', N'0'),
    (4082, 160, N'Capatan', N'0'),
    (10258, 393, N'Congbalay-Legaspi', N'0'),
    (10345, 397, N'Ibayo Silangan', N'0'),
    (11209, 432, N'Macasipac', N'0'),
    (11844, 451, N'Vegaflor', N'0'),
    (12750, 491, N'Sawi', N'0'),
    (13559, 526, N'Pasig', N'0'),
    (14108, 558, N'Calunacon', N'0'),
    (14502, 570, N'Tambo', N'0'),
    (14624, 575, N'Bagumbayan', N'0'),
    (15838, 616, N'San Vicente Ogbon', N'0'),
    (16453, 640, N'Burgos', N'0'),
    (16542, 642, N'Amotag', N'0'),
    (16739, 648, N'Peñafrancia', N'0'),
    (16958, 658, N'Dangpanan', N'0'),
    (17763, 684, N'Linabuan Norte', N'0'),
    (18624, 716, N'Jambad', N'0'),
    (19573, 746, N'Ermita', N'0'),
    (19844, 750, N'San Nicolas', N'0'),
    (21303, 789, N'La Granja', N'0'),
    (21378, 794, N'Buenavista Rizal', N'0'),
    (21854, 819, N'Nueva Montana', N'0'),
    (22952, 866, N'Matun-og', N'0'),
    (23301, 880, N'Casay', N'0'),
    (24081, 915, N'Tangculogan', N'0'),
    (25013, 954, N'Barangay Poblacion 8', N'0'),
    (25239, 963, N'Tan-awan', N'0'),
    (26397, 995, N'Barangay 25 (Pob.)', N'0'),
    (28171, 1049, N'Cabunga-an', N'0'),
    (28710, 1067, N'San Jose', N'0'),
    (28847, 1073, N'Looc', N'0'),
    (28961, 1079, N'Canila', N'0'),
    (28983, 1081, N'Binohangan', N'0'),
    (30177, 1126, N'San Pedro (Pob.)', N'0'),
    (30298, 1131, N'New Village (Pob.)', N'0'),
    (31659, 1190, N'Mamagum', N'0'),
    (32311, 1218, N'Mohon', N'0'),
    (32811, 1236, N'Salicapawan', N'0'),
    (33025, 1252, N'Guadalupe', N'0'),
    (33219, 1261, N'Pinamuno', N'0'),
    (33764, 1280, N'San Ignacio', N'0'),
    (34370, 1307, N'Kabulacan', N'0'),
    (34843, 1324, N'Lampitak', N'0'),
    (35205, 1343, N'Glan Padidu', N'0'),
    (35372, 1350, N'Barangay 15', N'0'),
    (36602, 1356, N'Barangay 112', N'0'),
    (36872, 1364, N'Barangay 44', N'0'),
    (37150, 1373, N'Lub-lubba', N'0'),
    (37464, 1395, N'Teodora Alonzo', N'0'),
    (38049, 1432, N'Buringal', N'0'),
    (38703, 1463, N'Pangadapun', N'0'),
    (39078, 1474, N'Diampaca', N'0'),
    (39464, 1487, N'Bangon Proper', N'0'),
    (39769, 1505, N'Manion', N'0'),
    (40245, 1538, N'Tayungan', N'0'),
    (41083, 1576, N'Piglawigan', N'0'),
    (41457, 1597, N'Cansayong', N'0'),
    (41680, 1611, N'San Jose', N'0')
) AS v ([Id], [AddressCityId], [Name], [Code])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[AddressTown] AS t WHERE t.[Id] = v.[Id]);
GO

INSERT INTO [Static].[AttachmentType] ([Id], [Name], [Description])
SELECT v.[Id], v.[Name], v.[Description]
FROM (VALUES
    (1, N'Individual', NULL),
    (2, N'Partner', NULL),
    (3, N'Group Policy Copy', NULL),
    (4, N'Group Declaration File', NULL),
    (5, N'Payments', NULL)
) AS v ([Id], [Name], [Description])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[AttachmentType] AS t WHERE t.[Id] = v.[Id]);
GO

INSERT INTO [Static].[ClaimsStatus] ([Id], [Name], [Description])
SELECT v.[Id], v.[Name], v.[Description]
FROM (VALUES
    (1, N'Reported', N'Notice of claim is made through DJDPatricio branch or direct to DJDPatricio Claims Team'),
    (2, N'Pending Requirements', N'Client to submit or has submitted partial document requirements for his/her claim'),
    (3, N'Processing', N'Client completes submission of claims requirements to DJDPatricio Claims'),
    (4, N'For Approval of Section Head', N'Claims Section Head reviews and approves the claim if amount is Within Settlement Authority (WSA is not more than Php60K)'),
    (5, N'For Approval of Claims Dept Head', N'Claims Department Head reviews and approves/disapproves all approvals made by Section Head, including claims payout processed via RAS (Remittance Agent System)'),
    (6, N'For Insurer''s Approval', N'Claims under the following conditions are subject to review and approval of Insurance Company (Pioneer): a) Benefit is above Php60K; b) All Emergency Expense Benefit Claim; c) Other Claims deemed for approval of insurer'),
    (7, N'Approved by Insurer', N'Claims submitted for insurer''s review is already approved and sends Letter of Authorization (LOA) or check (if applicable)'),
    (8, N'For Payment Processing', N'Claim is lined up for payment processing of DJDPatricio/Insurer'),
    (9, N'Ready for Release', N'Claim is now ready for release to claimant (with reference number)'),
    (10, N'Settled', N'Claims proceeds is released to client/claimant'),
    (11, N'Denied', N'Claim is denied either by DJDPatricio or Insurer'),
    (12, N'Pending Reimbursement', N'Claims forwarded to insurer for reimbursement'),
    (13, N'Reimbursed', N'Claims is already replenished/paid by insurer'),
    (14, N'For Ex-Gratia Processing', N'Denied claims that are subject for reconsideration upon submission of recommendation by DJDPatricio branch personnel'),
    (15, N'Ex-Gratia for Approval of Claims Department Head', N'Claims Lead submits the claim for ex-gratia for approval by Claims Department Head (rule: ex-gratia amount must not be more than Php500 per COC)'),
    (16, N'Ex-Gratia for Approval of Insurer', N'Claim is endorsed to Insurer for ex-gratia reconsideration'),
    (17, N'Ex-Gratia for Approval of Accounting Department Head', N'Ex-gratia amount is submitted to Accounting Head for validation (copy of approval of Group Head must be attached if ex-gratia amount is more than Php500/COC or Php2500)'),
    (18, N'For Ex-Gratia Payment Processing', N'Ex-gratia is approved by Accounting Head and will be processed for payout'),
    (19, N'Ready for release (Ex-Gratia)', N'Claim is now ready for release to claimant (with reference number)'),
    (20, N'Settled (Ex-Gratia)', N'Claims proceeds is released to client/claimant'),
    (21, N'Cancelled', N'Claim benefit is processed for release (with reference number) but are unclaimed for more than 20 working days'),
    (22, N'Reactivated for Payout', N'Claim benefit will be processed again for release to generate a new reference number for the payout upon receipt of claimant''s request'),
    (23, N'Archived', N'Claim pending for 10 working days with lacking requirements from clients')
) AS v ([Id], [Name], [Description])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[ClaimsStatus] AS t WHERE t.[Id] = v.[Id]);
GO

INSERT INTO [Static].[CocStatus] ([Id], [Name], [Description])
SELECT v.[Id], v.[Name], v.[Description]
FROM (VALUES
    (1, N'Active', N'COC in force; will be defined per benefit'),
    (2, N'Claimed', N'Refers to status of benefit if already claimed or not; will be defined per benefit'),
    (3, N'Expired', N'COC is terminated on last day of effectivity date (ex: Sept 3, 2020 to Jan 3, 2021)'),
    (4, N'Cancelled', N'Successful sales but client requested for cancellation due to valid reasons'),
    (5, N'Void', N'Sold COC’s but not yet encoded in the system and requested to tag as Void due to valid reasons'),
    (6, N'Inactive', N'Inactive COC')
) AS v ([Id], [Name], [Description])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[CocStatus] AS t WHERE t.[Id] = v.[Id]);
GO

INSERT INTO [Static].[PaymentStatus] ([Id], [Name], [Description])
SELECT v.[Id], v.[Name], v.[Description]
FROM (VALUES
    (1, N'Fully Paid', NULL),
    (2, N'Unpaid', NULL),
    (3, N'Partially Paid', NULL),
    (4, N'Cancelled', NULL),
    (5, N'Overpaid', NULL)
) AS v ([Id], [Name], [Description])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[PaymentStatus] AS t WHERE t.[Id] = v.[Id]);
GO

INSERT INTO [Static].[Platforms] ([Id], [Name], [Description], [Code])
SELECT v.[Id], v.[Name], v.[Description], v.[Code]
FROM (VALUES
    (1, N'SMS', N'for SMS based registration', N'SMS1'),
    (2, N'FWC Mobile App', N'FWC Mobile Application', N'FWCA'),
    (3, N'iClick 3.0', NULL, N'IC30'),
    (4, N'PeraLink App', NULL, N'PRLK'),
    (5, N'J6W Platform', N'J6W Digital Platform', N'J6WP'),
    (6, N'Bizmoto Platform', NULL, N'BIZP'),
    (7, N'Tagcash Platform', NULL, N'TAGP'),
    (8, N'DJDPatricio From Home', NULL, N'CFHS'),
    (9, N'DJDPatricio Microsite', NULL, N'CLMS'),
    (10, N'24K Website', N'DJDPatricio 24K members website', N'24KW'),
    (11, N'eDJDPatricio App', N'eDJDPatricio Application', N'ECEB'),
    (12, N'eTap Kiosk', N'eTap Digital Platform', N'ETAP'),
    (13, N'CMS 2.0', N'Proud cloud platform', N'CMS2'),
    (14, N'IMS 2.0', N'Insurance Management System v2', N'IMS2'),
    (15, N'MutiSys Platform', N'Multisys platform', N'MSYS'),
    (16, N'Action Able', N'Posible dot Net', N'ACAB'),
    (17, N'CMS Rapido', N'Filing of Rapido claims', N'CMSR'),
    (18, N'Togetech', N'Togetech new integration', N'TOGE'),
    (19, N'FortunePay', N'Fortune pay integration', N'FPAY'),
    (20, N'Togetech', N'Togetech integration', N'TOGT'),
    (21, N'IVA Platform', N'DJDPatricio Facebook Messenger AI Chatbot', N'IVAP'),
    (22, N'GCash', N'GCash App', N'GCSH'),
    (23, N'ProtectNow', N'DJDPatricio Insurance Platform', N'PNOW'),
    (24, N'CebX Insurance', N'Nano Insurance', N'CEBX'),
    (25, N'Ceb-OnTheGo', N'DJDPatricio On The Go Agent App', N'COTG'),
    (26, N'iClick 3.0 Qgen', N'Quotation Generator for iClick 3.0', N'IC3Q'),
    (27, N'IMS 3.0', N'Insurance Management System v3', N'IMS3')
) AS v ([Id], [Name], [Description], [Code])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[Platforms] AS t WHERE t.[Id] = v.[Id]);
GO

INSERT INTO [Static].[PolicyBookingStatus] ([Id], [Name], [Description])
SELECT v.[Id], v.[Name], v.[Description]
FROM (VALUES
    (1, N'Approved', NULL),
    (2, N'Disapproved', NULL),
    (3, N'Pending', NULL),
    (4, N'Declined', NULL),
    (5, N'Quoted', NULL),
    (6, N'Draft', NULL),
    (7, N'Auto-Approved', NULL)
) AS v ([Id], [Name], [Description])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[PolicyBookingStatus] AS t WHERE t.[Id] = v.[Id]);
GO

INSERT INTO [Static].[PolicyType] ([Id], [Name], [Description])
SELECT v.[Id], v.[Name], v.[Description]
FROM (VALUES
    (1, N'Individual', NULL),
    (2, N'Partner', NULL),
    (3, N'Group', NULL)
) AS v ([Id], [Name], [Description])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[PolicyType] AS t WHERE t.[Id] = v.[Id]);
GO

INSERT INTO [Static].[SelectionType] ([Id], [Name], [Description])
SELECT v.[Id], v.[Name], v.[Description]
FROM (VALUES
    (1, N'Valid Id Type', NULL),
    (2, N'Relationship', NULL),
    (3, N'Account Type', NULL),
    (4, N'Payment Option', NULL)
) AS v ([Id], [Name], [Description])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[SelectionType] AS t WHERE t.[Id] = v.[Id]);
GO

SET IDENTITY_INSERT [Reference].[SelectionList] ON;
INSERT INTO [Reference].[SelectionList] ([Id], [SelectionTypeId], [Name], [Description], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[SelectionTypeId], v.[Name], v.[Description], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, 1, N'Drivers License', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, 1, N'Passport', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, 1, N'SSS ID', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, 1, N'UMID', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, 1, N'Voters ID', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (6, 1, N'Philhealth ID', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, 2, N'Spouse', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, 2, N'Child', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (9, 2, N'Parent', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, 2, N'Sibling', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (11, 2, N'Grandparent', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (12, 2, N'Grandchild', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (13, 2, N'Aunt/Uncle', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (14, 2, N'Niece/Nephew', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (15, 2, N'Cousin', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (16, 2, N'Friend', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (17, 2, N'Other', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (18, 2, N'Partner', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (19, 2, N'Guardian', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (20, 2, N'Ward', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (21, 2, N'Employer', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (22, 2, N'Employee', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (23, 3, N'New', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (24, 3, N'Renewal', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (25, 3, N'Cancellation', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (26, 3, N'Additional', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (27, 4, N'Cash', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (28, 4, N'Credit Card', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (29, 4, N'Debit Card', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (30, 4, N'Bank Transfer', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (31, 4, N'Mobile Payment', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (32, 4, N'Online Payment Gateway', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (33, 4, N'E-Wallet', NULL, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [SelectionTypeId], [Name], [Description], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[SelectionList] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[SelectionList] OFF;
GO

SET IDENTITY_INSERT [Reference].[DistributionChannel] ON;
INSERT INTO [Reference].[DistributionChannel] ([Id], [Name], [Description], [Code], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[Name], v.[Description], v.[Code], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, N'Captive - DJDPatricio Branch', N'Insurance Clients directly related to PJLI employees, Owners and sales via DJDPatricio branches', N'CCLB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, N'Captive - DJDPatricio Digital', N'Insurance Clients directly solicited through DJDPatricio Digital Channels', N'CCLD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, N'Captive - DJDPatricio Affiliates', N'Insurance Clients directly solicited by affiliated companies of PJLI', N'CCLA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, N'Semi-Captive', N'Insurance Clients directly solicited or referred by employees of PJLI and its affiliated companies', N'SCAP', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, N'Non-Captive Agents', N'Insurance Clients directly solicited by registered agents of DJDPatricio', N'NCPA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (6, N'Non-Captive Digital', N'Insurance Clients directly solicited through Digital partnership', N'NCPD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, N'ADC - Mall Branches', NULL, N'CLIS', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, N'ADC2 - Mall Branches', NULL, N'DJDPatricio', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, N'BR Semi-Captive', NULL, N'SCBR', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [Name], [Description], [Code], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[DistributionChannel] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[DistributionChannel] OFF;
GO

SET IDENTITY_INSERT [Reference].[ProductCategory] ON;
INSERT INTO [Reference].[ProductCategory] ([Id], [Name], [Description], [Code], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[Name], v.[Description], v.[Code], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, N'Group Personal Insurance', N'Group Personal', N'GPI', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, N'Group Health Insurance', N'Group Health', N'GHI', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, N'Individual Health Insurance', N'Health', N'IHI', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, N'Individual Personal Insurance', N'Personal', N'IPI', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, N'Vehicle Insurance', N'Vehicle', N'VCI', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (6, N'Property Insurance', N'Property', N'PRI', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, N'Business Insurance', N'Business', N'BSI', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, N'Lifestyle Insurance', N'Liability', N'LIA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (9, N'Marine Insurance', N'Marine', N'MRI', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, N'Family Insurance', N'Family', N'FMI', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (11, N'Travel Insurance', N'Travel', N'TRI', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (12, N'Bonds', N'Bonds', N'BND', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (13, N'Engineering', N'Engineering', N'ENG', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (14, N'Life', N'Life', N'LFE', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (15, N'Others', N'Others', N'OIC', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [Name], [Description], [Code], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[ProductCategory] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[ProductCategory] OFF;
GO

SET IDENTITY_INSERT [Reference].[Products] ON;
INSERT INTO [Reference].[Products] ([Id], [ProductCategoryId], [Name], [Description], [Code], [MinimumAge], [MaximumAge], [MaximumBookingPerYear], [MaximumBookingPerDuration], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[ProductCategoryId], v.[Name], v.[Description], v.[Code], v.[MinimumAge], v.[MaximumAge], v.[MaximumBookingPerYear], v.[MaximumBookingPerDuration], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, 4, N'ProtectMax (Old)', N'Provides coverage for Death, Accident/Sickness Emergency Cash Assist, Accidental Dismemberment or Disablement, Murder and Unprovoked Assault and Fire cash assistance. For Age 7 to 70.', N'CLPMX', 7, 70, 15, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, 1, N'DJDPatricio PA Basic', N'Provides coverage for Accidental Death and Accidental Dismemberment and/or Disablement Benefit. Underwritten by Pioneer Ins. For age 18 to 70.', N'PAB15', 18, 70, 12, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, 1, N'DJDPatricio PA Basic Plus', N'Provides coverage for Accidental Death, Accidental Dismemberment and/or Disablement Benefit, and Fire Cash Assistance. Underwritten by Pioneer Ins. For Age 18 to 70.', N'PAB20', 18, 70, 12, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, 1, N'DJDPatricio PA Prime', N'Provides coverage for Acc. Death, Acc. Dismemberment or Disablement, Murder & Unprovoked Assault, Burial Benefit, & Fire Cash Assistance. Underwritten by Pioneer Ins. For Age 7 to 70.', N'PAPRM', 7, 70, 5, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, 1, N'DJDPatricio PA Basic Plus', N'Provides coverage for Accidental Death, Accidental Dismemberment and/or Disablement Benefit, and Fire Cash Assistance. Underwritten by Malayan Ins. For age 18 to 70.', N'MPABP', 18, 70, 48, 4, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (6, 1, N'DJDPatricio PA Basic', N'Provides coverage for Accidental Death and Accidental Dismemberment and/or Disablement Benefit. Underwritten by Malayan Ins. For age 18 to 70.', N'CLPAB', 18, 70, 12, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, 1, N'DJDPatricio PA Prime', N'Provides coverage for Acc. Death, Acc. Dismemberment or Disablement, Murder & Unprovoked Assault, Burial Benefit, & Fire Cash Assistance. Underwritten by Malayan Ins. For Age 7 to 70.', N'CLPRM', 7, 70, 5, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, 1, N'MyCare', N'Provides coverage for Accidental Death and Accidental Dismemberment and/or Disablement Benefit. Underwritten by Pioneer Ins. For age 18 to 70.', N'MYCRE', 18, 70, 12, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (9, 1, N'Free DJDPatricio PA', N'Free DJDPatricio PA is an Ins. that provides coverage for Accidental Death and Accidental Dismemberment and/or Disablement Benefit. Free DJDPatricio PA is a Free Product. For age 18 to 70.', N'ECPABASIC', 18, 70, 12, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, 3, N'DJDPatricio ER Care 10K', N'Covers the medical expenses for eligible emergency condition. Availment can be In/Out Patient in a hospital. For age 0 to 65.', N'CLER1', 0, 65, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (11, 3, N'DJDPatricio ER Care 20K', N'Covers the medical expenses for eligible emergency condition. Availment can be In/Out Patient in a hospital. For age 0 to 65.', N'CLER2', 0, 65, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (12, 3, N'DJDPatricio ER Care 5K', N'Covers the medical expenses for eligible emergency condition. Availment can be In/Out Patient in a hospital. For age 0 to 65.', N'CLER5', 0, 65, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (13, 3, N'DJDPatricio Health Dengue', N'Provides cash assistance benefit of 10K if the insured was diagnosed with Dengue. For age 1 to 70.', N'CLHDE', 1, 70, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (14, 3, N'DJDPatricio Health Dengue Plus', N'Provides cash assistance benefit of 10K if the insured was diagnosed with Dengue, plus coverage for accidental death, accidental dismemberment and/or disablement Ins. For age 1 to 70', N'CLHDP', 1, 70, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (15, 3, N'DJDPatricio Health Leptospirosis', N'Provides cash assistance benefit of 10K if the insured was diagnosed with Leptospirosis. For age 1 to 70.', N'CLHLE', 1, 70, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (16, 3, N'DJDPatricio Health Max', N'Provides coverage ER Care Coverage, Med Assist Coverage, and TeleConsultation calls. For age 1 to 60.', N'CLHMX', 0, 60, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (17, 3, N'DJDPatricio Med Assist 2', N'Provides medicince reimbursement like vitamins, and prescribed medicine following the discharge from Hospital Confinement. For age 1 to 60.', N'CLMA2', 0, 60, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (18, 3, N'DJDPatricio Med Assist 2.5', N'Provides medicince reimbursement like vitamins, and prescribed medicine following the discharge from Hospital Confinement. For age 1 to 60.', N'CLMA3', 0, 60, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (19, 3, N'DJDPatricio Med Assist 5', N'Provides medicince reimbursement like vitamins, and prescribed medicine following the discharge from Hospital Confinement. For age 1 to 60.', N'CLMA5', 0, 60, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (20, 3, N'DJDPatricio Tele Care 10', N'Provides round-the-clock doctor consultation whenever, wherever. The licensed doctors are available 24 hours a day, 7 days a week. For age 1 to 99.', N'CLTC1', 0, 99, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (21, 3, N'DJDPatricio Tele Care 6', N'Provides round-the-clock doctor consultation whenever, wherever. The licensed doctors are available 24 hours a day, 7 days a week. For age 1 to 99.', N'CLTC6', 0, 99, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (22, 3, N'DJDPatricio Tele Care Unli', N'Provides round-the-clock doctor consultation whenever, wherever. The licensed doctors are available 24 hours a day, 7 days a week. For age 1 to 99.', N'CLTCU', 0, 99, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (23, 3, N'MediCash Dengue', N'Provides cash assistance benefit of 10K if the insured was diagnosed with Dengue. For age 1 to 70.', N'DJDDEN', 1, 70, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (24, 3, N'MediCash Leptospirosis', N'Provides cash assistance benefit of 10K if the insured was diagnosed with Leptospirosis. For age 1 to 70.', N'DJDLEP', 1, 70, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (25, 5, N'eCTPL', N'CTPL Insurance provides financial protection against injury and/or death caused by collisions for persons other than the passengers and the driver. Required by the LTO in registration of motor units.', N'DJDTPL', 18, 100, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (26, 5, N'CTPL', N'CTPL Insurance provides financial protection against injury and/or death caused by collisions for persons other than the passengers and the driver. Required by the LTO in registration of motor units.', N'FCTPL', 18, 100, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (27, 5, N'Compre - 4 wheels', N'AutoCARE is a comprehensive motor car insurance available to vehicles used for private business and leisure. This product is underwritten by Pioneer Insurance.', N'PC4WH', 18, 100, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (28, 5, N'Compre - 4 wheels', N'AutoCARE is a comprehensive motor car insurance available to vehicles used for private business and leisure. This product is underwritten by FPG Insurance.', N'FC4WH', 18, 100, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (29, 5, N'Compre - 4 wheels', N'AutoCARE is a comprehensive motor car insurance available to vehicles used for private business and leisure. This product is underwritten by Malayan Insurance.', N'DJD4WH', 18, 100, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (30, 5, N'Compre - 2 wheels', N'MotorCARE is a comprehensive motor car insurance available to 2-wheeled vehicles used for private, business and leisure.', N'DJD2WH', 18, 100, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (31, 1, N'Retail Agents', N'The Retail Agents Ins. is product specifically designed for the Retail Agents of DJDPatricio Lhuillier. For age 18 to 64.', N'PLARA', 18, 64, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (32, 2, N'DJDPatricio Health Care', N'Provides cover to Accidental Death and Disability (AD&D), Double Indemnity, 24/7 Call-a-doc, OP ER One Time use and Daily Hospital Income Benefit. For age 18 to 65.', N'CLHC1', 18, 65, 5, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (33, 2, N'DJDPatricio Care', N'Provides cover to Accidental Death and Disability (AD&D), Double Indemnity, Group Yearly Renewable Term Life (GYRT) (Burial Assistance) and Call-a-doc. For age 18 to 65.', N'CLCAR', 18, 65, 5, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (34, 1, N'DJDPatricio PA Prime 6', N'Provides coverage for Acc. Death, Acc. Dismemberment or Disablement, Murder & Unprovoked Assault, Burial Benefit, & Fire Cash Assistance. Underwritten by Malayan Ins. For Age 7 to 70.', N'CLPR6', 7, 70, 5, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (35, 4, N'DJDPatricio Rider Care', N'Provides coverage for Acc. Death, Acc. Dismemberment or Disablement, Burial Benefit, AMR, TeleCare, & DHIB. Underwritten by Generali. For Age 18 to 65.', N'ECRC2', 18, 65, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (36, 3, N'DJDPatricio Covid-19 Plus 100K 1-64yrs', N'Provides Coverage for Death due to Accident, Covid-19, Dengue, and Chikungunya, Medical Reimbursement due to accident, and Hospital Income Benefit due to Covid-19. For Age 1 to 64.', N'CVPA1', 1, 64, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (37, 3, N'DJDPatricio Covid-19 Plus 200K 1-64yrs', N'Provides Coverage for Death due to Accident, Covid-19, Dengue, and Chikungunya, Medical Reimbursement due to accident, and Hospital Income Benefit due to Covid-19. For Age 1 to 64.', N'CVPB1', 1, 64, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (38, 3, N'DJDPatricio Covid-19 Plus 300K 1-64yrs', N'Provides Coverage for Death due to Accident, Covid-19, Dengue, and Chikungunya, Medical Reimbursement due to accident, and Hospital Income Benefit due to Covid-19. For Age 1 to 64.', N'CVPC1', 1, 64, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (39, 3, N'DJDPatricio Covid-19 Plus 25K  1-64yrs', N'Provides Coverage for Death due to Accident, Covid-19, Dengue, and Chikungunya, Medical Reimbursement due to accident, and Hospital Income Benefit due to Covid-19. For Age 1 to 64.', N'CVPD1', 1, 64, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (40, 3, N'DJDPatricio Covid-19 Plus 12.5K 1-64yr', N'Provides Coverage for Death due to Accident, Covid-19, Dengue, and Chikungunya, Medical Reimbursement due to accident, and Hospital Income Benefit due to Covid-19. For Age 1 to 64.', N'CVPE1', 1, 64, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (41, 3, N'DJDPatricio Covid-19 Plus 100K 65-75yrs', N'Provides Coverage for Death due to Accident, Covid-19, Dengue, and Chikungunya, Medical Reimbursement due to accident, and Hospital Income Benefit due to Covid-19. For Age 65 to 75.', N'CVPA2', 65, 75, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (42, 3, N'DJDPatricio Covid-19 Plus 200K 65-75yrs', N'Provides Coverage for Death due to Accident, Covid-19, Dengue, and Chikungunya, Medical Reimbursement due to accident, and Hospital Income Benefit due to Covid-19. For Age 65 to 75.', N'CVPB2', 65, 75, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (43, 3, N'DJDPatricio Covid-19 Plus 300K 65-75yrs', N'Provides Coverage for Death due to Accident, Covid-19, Dengue, and Chikungunya, Medical Reimbursement due to accident, and Hospital Income Benefit due to Covid-19. For Age 65 to 75.', N'CVPC2', 65, 75, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (44, 3, N'DJDPatricio Covid-19 Plus 25K 65-75yrs', N'Provides Coverage for Death due to Accident, Covid-19, Dengue, and Chikungunya, Medical Reimbursement due to accident, and Hospital Income Benefit due to Covid-19. For Age 65 to 75.', N'CVPD2', 65, 75, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (45, 3, N'DJDPatricio Covid-19 Plus 12.5K 65-75yr', N'Provides Coverage for Death due to Accident, Covid-19, Dengue, and Chikungunya, Medical Reimbursement due to accident, and Hospital Income Benefit due to Covid-19. For Age 65 to 75.', N'CVPE2', 65, 75, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (46, 4, N'Free DJDPatricio PA', N'Free DJDPatricio PA is an Ins. that provides coverage for Accidental Death and Accidental Dismemberment and/or Disablement Benefit. Free DJDPatricio PA is a Free Product. For age 18 to 70.', N'FRPAB', 18, 70, 12, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (47, 8, N'DJDPatricio Pet Care(Option 1)', N'Provides coverage for Dogs Medical Reimbursement, Burial Assistance, Owners Liability, and Personal Accident for the Owner. For Dogs age 6 months to 8 Years.', N'CLPTC', 18, 64, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (48, 5, N'eCTPL', N'CTPL Ins. provides protection against injury and/or death caused by collisions for persons other than the passengers and the driver. Required by the LTO in registration of motor units. 3 Year Coverage', N'DJDTP3', 18, 70, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (49, 4, N'Pamilya Care', N'Pamilya Care provides a 1 year coverage against Accidental Death and Disablement (AD&D), Unprovoked Murder and Assault, Accidental Medical Reimbursement and Cash Assistance Benefit.', N'PCFPG', 18, 65, 4, 4, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (50, 2, N'DJDPatricio Health Care', N'Provides cover to Accidental Death and Disability (AD&D), Double Indemnity, 24/7 Call-a-doc, OP ER One Time use and Daily Hospital Income Benefit. For age 18 to 65.', N'CLHC2', 18, 65, 5, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (51, 1, N'DJDPatricio Nano Insurance', N'Provides one (1) mont cover for Accidental Death and Disablement, Permanent Disablement/Dismemberment, and Cash Assistance due to Food Poisoning. For Age 18 to 64', N'CLNIF', 18, 64, 120, 10, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (54, 4, N'DJDPatricio Nano Insurance', N'Provides Six (6) months Cover for Accidental Death and Disablement, Permanent Disablement/Dismemberment. For Age 18 to 64', N'CLNF6', 18, 64, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (55, 8, N'DJDPatricio Pet Care(Option 2)', N'Provides coverage for Dogs Medical Reimbursement, Burial Assistance, Owners Liability, and Personal Accident for the Owner. For Dogs age 6 months to 8 Years.', N'CLPT2', 18, 64, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (56, 8, N'DJDPatricio Pet Care(Option 3)', N'Provides coverage for Dogs Medical Reimbursement, Burial Assistance, Owners Liability, and Personal Accident for the Owner. For Dogs age 6 months to 8 Years.', N'CLPT3', 18, 64, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (57, 8, N'DJDPatricio Pet Care(Option 4)', N'Provides coverage for Dogs Medical Reimbursement, Burial Assistance, Owners Liability, and Personal Accident for the Owner. For Dogs age 6 months to 8 Years.', N'CLPT4', 18, 64, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (58, 8, N'DJDPatricio Pet Care(Option 5)', N'Provides coverage for Dogs Medical Reimbursement, Burial Assistance, Owners Liability, and Personal Accident for the Owner. For Dogs age 6 months to 8 Years.', N'CLPT5', 18, 64, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (59, 4, N'DJDPatricio Bikers Care', N'Provides coverage for Acc. Death, Acc. Dismemberment or Disablement, Acc. Burial Benefit, AMR, Fire, MUA, Personal Liability & DHIB. Underwritten by BPI/MS. For Age 18 to 65.', N'CLBC1', 18, 65, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (60, 5, N'DJDPatricio Autocare / Motorcare', N'AutoCARE is a comprehensive motor car insurance available to vehicles used for private business and leisure. This product is underwritten by FPG Insurance.', N'CLAC', 18, 100, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (61, 4, N'DJDPatricio Nano Insurance (5K)', N'Povides Cover for Accidental Death and Disablement, Permanent Disablement/Dismemberment. For Age 18 to 64', N'CLN5K', 18, 64, 120, 10, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (62, 4, N'DJDPatricio Nano Plus Insurance', N'Povides Cover for Accidental Death and Disablement, Permanent Disablement/Dismemberment, Accidental Medical Reimbursement, Accident Burial, Cash Assistance, Fire Cash Assistance. For Age 18 to 64', N'CLNP1', 18, 64, 20, 10, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (63, 4, N'DJDPatricio Personal Insurance', N'Provides Coverage for Accidental Death & Disablement, Death due to Morotcycling, and Burial Cash Assistance due to any causes', N'CLPRA', 18, 72, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (64, 4, N'DJDPatricio Driver Care', N'Covers Acc. Death, Dismemberment, & Disablement, Murder & Unprovoked Assault, Acc. Medical Reimbursement, Acc. Burial Benefit, Daily Hospital Income, and Fire Cash Assistance. For Age 18 to 65', N'DJDLDC', 18, 65, 5, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (65, 4, N'DJDPatricio Employee Care', N'Covers Acc. Death, Dismemberment, & Disablement, Acc. Medical Reimbursement, Acc. Burial Benefit, Murder and Unprovoked Assault, Personal Liability, and Daily Hospital Income. For Age 18 to 65', N'DJDLEC', 18, 65, 5, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (66, 4, N'KanMend', N'Term insurance plan that provides benefit upon the Insured’s diagnosis of any of the covered Critical Illness. For age 18 to 50', N'KNMND', 18, 50, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (67, 4, N'KanLive', N'Term insurance plan that provides benefit upon the Insured’s death. For age 18 to 50', N'KNLIV', 18, 50, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (68, 4, N'KanGuard', N'Term insurance plan that provides benefit upon the Insured’s death due to accident or terrorism and disability due to terrorism. For age 18 to 50', N'KNGRD', 18, 50, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (69, 4, N'DJDPatricio Nano Insurance (CebX)', N'Povides Cover for Accidental Death and Disablement, Permanent Disablement/Dismemberment. For Age 18 to 64', N'CLNCX', 18, 64, 12, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (70, 4, N'DJDPatricio ProtectMax Jr.', N'Provides Death Benefit coverage, Accidental Death Dismemberment, and Disability, Total Permanent Disability, and Emergency Cash Assistance Benefit', N'CLPMJ', 7, 70, 60, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (71, 4, N'DJDPatricio PA Basic', N'Provides coverage for Accidental Death and Accidental Dismemberment and/or Disablement Benefit. Underwritten by Malayan Ins. For age 18 to 70.', N'CLPB2', 18, 70, 60, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (72, 4, N'DJDPatricio ProtectMax (12 Mos)', N'Provides coverage for Death, Accident/Sickness Emergency Cash Assist, Accidental Dismemberment or Disablement, Murder and Unprovoked Assault and Fire cash assistance. For Age 7 to 70.', N'CLPMP', 7, 70, 5, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (73, 4, N'DJDPatricio ProtectMax (4 Mos)', N'Provides coverage for Death, Accident/Sickness Emergency Cash Assist, Accidental Dismemberment or Disablement, Murder and Unprovoked Assault and Fire cash assistance. For Age 7 to 70.', N'CLPM2', 7, 70, 15, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (74, 4, N'DJDPatricio All Day Care', N'Provides coverage for Acc. Death, Acc. Dismemberment or Disablement, Murder & Unprovoked Assault, Burial Benefit, Fire Cash Assistance, & TeleHealth. For Age 18 to 65', N'CLADC', 18, 65, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (75, 3, N'DJDPatricio HealthMax', N'Provides coverage for Basic Hospital Benefit, Critical Care, Surgical, and Emergency Benefit for Viral and Bacterial Illnesses and treatment of injuries resulting from accidents. For age 0 to 65.', N'HMX3K', 0, 65, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (76, 4, N'DJDPatricio Miners ProtectMax', N'Provides coverage for Death, Accident/Sickness Emergency Cash Assist, Accidental Dismemberment or Disablement, Murder and Unprovoked Assault and Fire cash assistance for Miners. For Age 18 to 60.', N'CLMPX', 18, 60, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (77, 4, N'DJDPatricio Miners Care', N'Provides coverage for Accidental Death and Accidental Dismemberment and/or Disablement Benefit for miners. Underwritten by Stronghold Insurance. For age 18 to 60.', N'CLMNC', 18, 60, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (78, 8, N'Screen Protect Yearly Plan 1', N'An insurance which covers phone screen repair for accidental and liquid damage to your phone screen.', N'ISPY1', 0, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (79, 8, N'Screen Protect Yearly Plan 2', N'An insurance which covers phone screen repair for accidental and liquid damage to your phone screen.', N'ISPY2', 0, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (80, 8, N'Screen Protect Yearly Plan 3', N'An insurance which covers phone screen repair for accidental and liquid damage to your phone screen.', N'ISPY3', 0, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (81, 8, N'Screen Protect Yearly Plan 4', N'An insurance which covers phone screen repair for accidental and liquid damage to your phone screen.', N'ISPY4', 0, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (82, 8, N'Screen Protect Yearly Plan 5', N'An insurance which covers phone screen repair for accidental and liquid damage to your phone screen.', N'ISPY5', 0, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (83, 8, N'Screen Protect Yearly Plan 6', N'An insurance which covers phone screen repair for accidental and liquid damage to your phone screen.', N'ISPY6', 0, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (84, 8, N'Screen Protect Monthly Plan 1', N'An insurance which covers phone screen repair for accidental and liquid damage to your phone screen.', N'ISMY1', 0, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (85, 8, N'Screen Protect Monthly Plan 2', N'An insurance which covers phone screen repair for accidental and liquid damage to your phone screen.', N'ISMY2', 0, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (86, 8, N'Screen Protect Monthly Plan 3', N'An insurance which covers phone screen repair for accidental and liquid damage to your phone screen.', N'ISMY3', 0, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (87, 8, N'Screen Protect Monthly Plan 4', N'An insurance which covers phone screen repair for accidental and liquid damage to your phone screen.', N'ISMY4', 0, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (88, 8, N'Screen Protect Monthly Plan 5', N'An insurance which covers phone screen repair for accidental and liquid damage to your phone screen.', N'ISMY5', 0, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (89, 8, N'Screen Protect Monthly Plan 6', N'An insurance which covers phone screen repair for accidental and liquid damage to your phone screen.', N'ISMY6', 0, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (90, 6, N'DJDPatricio Home Care', N'Provides coverage for Fire and other damages done to the property for Owners and Tenants', N'CLMHM', 18, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (91, 9, N'DJDPatricio Marine Insurance', N'Provides financial protection against damages regarding transported goods or packages.', N'CLMAR', 18, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (92, 10, N'DJDPatricio PamilyaCare Plus', N'Provides a 1-year coverage against Accidental Death and Disablement (AD&D).', N'CLPPT', 18, 65, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (93, 4, N'DJDPatricio Miners ProtectMax', N'Provides coverage for Death, Accident/Sickness Emergency Cash Assist, Accidental Dismemberment or Disablement, Murder and Unprovoked Assault and Fire cash assistance for Miners. For Age 18 to 60.', N'CLMP2', 18, 60, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (94, 6, N'DJDPatricio Sunog Safe', N'Offers financial aid to cover damages caused by fire or lightning to the insured property.', N'CLMF3', 18, 99, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (95, 4, N'DJDPatricio Test Product', N'Covers Acc. Death, Dismemberment, & Disablement, Acc. Medical Reimbursement, Acc. Burial Benefit, Murder and Unprovoked Assault, Personal Liability, and Daily Hospital Income. For Age 18 to 65', N'TSP01', 18, 65, 10, 10, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (96, 7, N'Traditional CGLI', N'Covers legal Liability against Bodily Injury and Property Damage that may arise due to accident in connection with the assured’s business operation and/or occupancy.', N'BCGLI', 1, 99, 1000, 1000, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (97, 7, N'Traditional CPL', N'Covers the expenses from legal liability to TPL arising from acc. property damage and/or bodily injury within the context of the policyholder''s private life as opposed to professional life.', N'BCPLI', 18, 65, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (98, 7, N'Traditional Events Liability', N'Covers Legal Liability of the insured for actual or compensatory damages to TP in respect of acc. BI and or PD arising from orgnizing the insured event to be held within the declared location of risk.', N'BEVLI', 1, 99, 100, 100, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (99, 7, N'Traditional Products Liability', N'Covers Legal costs and damages against TPBI and or PD arising from products sold by a certain business entity.', N'BPRLI', 1, 99, 100, 100, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (100, 3, N'Critical Assist (12 Mos)', N'Provides cash benefit for diagnosis of or surgery due to any of the covered critical illness and cash benefit due to death. For ages 18-64.', N'CLCRA', 18, 65, 10, 10, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (101, 11, N'DJDPatricio Travel Care (Domestic)', N'Provides coverage to scheduled domestic travels within the Philippines', N'FPGDT', 0, 80, 99, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (102, 11, N'DJDPatricio Travel Care (Domestic) 50K', N'Provides coverage to scheduled domestic travels within the Philippines', N'FL50K', 0, 80, 99, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (103, 11, N'DJDPatricio Travel Care (Domestic) 100K', N'Provides coverage to scheduled domestic travels within the Philippines', N'FL100', 0, 80, 99, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (104, 11, N'DJDPatricio Travel Care (Domestic) 500K', N'Provides coverage to scheduled domestic travels within the Philippines', N'FL500', 0, 80, 99, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (105, 11, N'DJDPatricio Travel Care (Domestic) 750K', N'Provides coverage to scheduled domestic travels within the Philippines', N'FL750', 0, 80, 99, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (106, 11, N'DJDPatricio Travel Care (Domestic) 1M', N'Provides coverage to scheduled domestic travels within the Philippines', N'FL1MN', 0, 80, 99, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (107, 11, N'DJDPatricio Travel Care (International)', N'DJDPatricio Travel Insurance provides coverage for PA, Medical Reimbursement, Trip Cancellation, Curtailment reimbursement, Lost or Delayed Baggage, Personal Liability, Medical Evacuation and Repatriation.', N'FPGIT', 0, 80, 99, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (108, 11, N'DJDPatricio Travel Care (International) 1M', N'DJDPatricio Travel Insurance provides coverage for PA, Medical Reimbursement, Trip Cancellation, Curtailment reimbursement, Lost or Delayed Baggage, Personal Liability, Medical Evacuation and Repatriation.', N'FI01M', 0, 80, 99, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (109, 11, N'DJDPatricio Travel Care (International) 2.5M', N'DJDPatricio Travel Insurance provides coverage for PA, Medical Reimbursement, Trip Cancellation, Curtailment reimbursement, Lost or Delayed Baggage, Personal Liability, Medical Evacuation and Repatriation.', N'FI25M', 0, 80, 99, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (110, 11, N'DJDPatricio Travel Care (International) 5M', N'DJDPatricio Travel Insurance provides coverage for PA, Medical Reimbursement, Trip Cancellation, Curtailment reimbursement, Lost or Delayed Baggage, Personal Liability, Medical Evacuation and Repatriation.', N'FI05M', 0, 80, 99, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (111, 4, N'DJDPatricio Protect Basic', N'Provides Death Benefit coverage, and Accident or Sickness Emergency Cash Assistance. For Age 7 to 70.', N'CLPMB', 7, 70, 15, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (112, 5, N'CTPL - Allied Bankers', N'CTPL Insurance provides financial protection against injury and/or death caused by collisions for persons other than the passengers and the driver. Required by the LTO in registration of motor units.', N'TPLAB', 18, 100, 9999, 9999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (113, 10, N'DJDPatricio Family PA', N'Provides a 1-year coverage against Accidental Death and Disablement (AD&D).', N'CLPPK', 18, 65, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (114, 3, N'DJDPatricio Mind Care', N'A multiple-use healthcare plan with a coverage up to P20K for ER and Hospitalization due to Accidents, unlimited Mental Health Benefits, and coverage for both Natural and Accidental Death.', N'CLMTC', 1, 65, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (115, 8, N'DJDPatricio Pet Protect 50K', N'Provides protection for your pet dogs and cats covering Accidental Death, Accidental Medical Reimbursement, Emergency Medical Assistance, and Accidental Death benefit for the pet owner.', N'PETCD', 18, 65, 4, 4, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (116, 12, N'Surety (Downpayment) Bond', N'Guarantees the recoupment of the downpayment given by the obligee to the principal through deductions from the progress billings submitted by the latter and approved by the obligee.', N'CLSBN', 18, 99, 100, 100, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (117, 12, N'Bidder’s Bond', N'Guarantees that the successful bidder (principal) shall enter into contract with the project owner or general contractor (obligee) and furnish the required Performance Bond.', N'CLBBN', 18, 99, 100, 100, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (118, 12, N'Performance Bond', N'A financial guarantee that the terms of a contract will be honored.', N'CLPBN', 18, 99, 100, 100, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (119, 12, N'Warranty Bond', N'Guarantees the repair of hidden defects in the materials and workmanship used by the principal in the project found within one year from the date of final acceptance by the obligee.', N'CLWBN', 18, 99, 100, 100, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (120, 12, N'Fedility Bond', N'Seeks to cover an employer against loss of money or of any other kind of property, whether real or personal, arising from the fraudulent or dishonest acts of the employees covered.', N'CLFBN', 18, 99, 100, 100, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (121, 12, N'Heir''s Bond', N'Answers for any claims filed by third parties who have been deprived of participation in the estate of a deceased person within a period of two years from settlement.', N'CLHBN', 18, 99, 100, 100, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (122, 13, N'Contractor''s All Risk', N'A non-standard insurance policy that provides coverage for property damage and third-party injury or damage claims.', N'CLCRI', 18, 99, 100, 100, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (123, 13, N'Industrial All Risk', N'Covers property damage, business interruption, liability, and other related risks. Property damage coverage protects against damage to buildings, equipment, and other property owned by the business.', N'CLIAR', 18, 99, 100, 100, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (124, 13, N'Erection All Risk', N'Covers loss or damage to projects that involves erection/installation of plant, machinery and equipment ranging from erection of a single machine to a large power plant.', N'CLEAR', 18, 99, 100, 100, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (125, 13, N'Machinery Breakdown', N'Covers accidental breakdown and physical damage of the machinery and the cost of repairs or replacement of the damaged machine part.', N'CLMBD', 18, 99, 100, 100, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (126, 14, N'Test Product Life', N'Test Product for Life Insurance', N'TLIFE', 0, 99, 999, 999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (127, 6, N'DJDPatricio Fire Insurance', N'Provides protection to properties against damages/lossess caoused by named perils.', N'CLTFI', 18, 100, 999, 999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (128, 7, N'DJDPatricio Fidelity Guarantee', N'Covers the employer against the loss of money, loss of stock or property which might result from acts of dishonesty by an employee in the course of employment', N'CLFGI', 18, 99, 100, 100, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (129, 7, N'DJDPatricio MSPR', N'Provides protection to business establishment against loss of money, securities or payrolls due to robbery', N'CMSPR', 18, 99, 100, 100, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (130, 4, N'DJDPatricio All Day Care', N'Provides coverage for Accidental Death, Accidental Dismemberment or Disablement, Fire Cash Assistance, & TeleHealth. For Age 18 to 65', N'CFADC', 18, 65, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (131, 14, N'DJDPatricio Abundance 20', N'Provides financial security and savings with guaranteed cash payouts, maturity benefits, and protection in case of death or terminal illness for 20 years.', N'CLA20', 0, 60, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (132, 14, N'DJDPatricio Abundance 65', N'Provides financial security and savings with guaranteed cash payouts, maturity benefits, and protection in case of death or terminal illness until age 65.', N'CLA65', 0, 45, 1, 1, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (133, 4, N'DJDPatricio Takaful Insurance', N'This Shariah-compliant coverage offers financial security through benefits for Accidental Death, Disability, and daily Hospital Cash Allowance for extended confinement.', N'TKFUL', 18, 65, 5, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (134, 7, N'DJDPatricio Comprehensive General Liability', N'Covers legal Liability against Bodily Injury and Property Damage that may arise due to accident in connection with the assured’s business operation and/or occupancy.', N'CLCGL', 18, 99, 5, 5, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (135, 7, N'DJDPatricio Comprehensive General Liability (50K)', N'Covers legal Liability against Bodily Injury and Property Damage that may arise due to accident in connection with the assured’s business operation and/or occupancy.', N'CGL50', 18, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (136, 7, N'DJDPatricio Comprehensive General Liability (100K)', N'Covers legal Liability against Bodily Injury and Property Damage that may arise due to accident in connection with the assured’s business operation and/or occupancy.', N'CGL1K', 18, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (137, 7, N'DJDPatricio Comprehensive General Liability (200K)', N'Covers legal Liability against Bodily Injury and Property Damage that may arise due to accident in connection with the assured’s business operation and/or occupancy.', N'CGL2K', 18, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (138, 7, N'DJDPatricio Comprehensive General Liability (300K)', N'Covers legal Liability against Bodily Injury and Property Damage that may arise due to accident in connection with the assured’s business operation and/or occupancy.', N'CGL3K', 18, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (139, 7, N'DJDPatricio Comprehensive General Liability (400K)', N'Covers legal Liability against Bodily Injury and Property Damage that may arise due to accident in connection with the assured’s business operation and/or occupancy.', N'CGL4K', 18, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (140, 7, N'DJDPatricio Comprehensive General Liability (500K)', N'Covers legal Liability against Bodily Injury and Property Damage that may arise due to accident in connection with the assured’s business operation and/or occupancy.', N'CGL5K', 18, 99, 99, 99, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (141, 14, N'Credit Group Life', N'Provides financial protection for your loved ones by paying off your outstanding loan balance in the event of your unexpected death.', N'CGLIF', 18, 69, 1000, 1000, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (142, 3, N'Critical Assist (12 Mos)', N'Provides cash benefit for diagnosis of or surgery due to any of the covered critical illness and cash benefit due to death. For ages 18-64.', N'CRITA', 18, 65, 10, 10, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (143, 9, N'Marine Hull', N'Provides financial protection against damages regarding transported goods or packages.', N'MHULL', 18, 65, 999, 999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (144, 9, N'Marine Cargo', N'Provides financial protection against damages regarding transported goods or packages.', N'DJDRGO', 18, 65, 999, 999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (145, 1, N'DJDPatricio Student Care', N'Provides protection protection to a group of people in case of accidents resulting in injury, disability, or death', N'CLSUC', 1, 65, 9999, 9999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (146, 1, N'DJDPatricio Tanod Care', N'Provides protection to a group of people in case of accidents resulting in injury, disability, or death', N'CLTAC', 18, 80, 9999, 9999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (147, 1, N'DJDPatricio Toda Care', N'Provides protection protection to a group of people in case of accidents resulting in injury, disability, or death', N'CLTOC', 18, 80, 9999, 9999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (148, 1, N'DJDPatricio Security Care', N'Provides protection protection to a group of people in case of accidents resulting in injury, disability, or death', N'CLSEC', 18, 65, 9999, 9999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (149, 1, N'DJDPatricio Builders Care', N'Provides protection protection to a group of people in case of accidents resulting in injury, disability, or death', N'CLBUC', 18, 65, 9999, 9999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (150, 5, N'DJDPatricio Motor Fleet', N'Provides protection to business vehicles and drivers', N'CLMFL', 18, 65, 9999, 9999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (151, 6, N'CLP Care', N'Provides protection to organization''s property from fire damage and third-party liabilities', N'CLPCF', 18, 65, 9999, 9999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (152, 15, N'Travel Insurance', N'Covers medical, cancellations, lost luggage, delays, liability.', N'CLTRI', 0, 95, 9999, 9999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (153, 15, N'AVIATION', N'Covers aircraft, liability, passengers, cargo. Protecting your aviation assets and operations.', N'CLAVI', 18, 99, 9999, 9999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (154, 15, N'Cyber Insurance', N'Protects against data breaches, cyberattacks, business interruption, and liability.', N'CLCYI', 18, 99, 9999, 9999, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [ProductCategoryId], [Name], [Description], [Code], [MinimumAge], [MaximumAge], [MaximumBookingPerYear], [MaximumBookingPerDuration], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[Products] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[Products] OFF;
GO

SET IDENTITY_INSERT [Reference].[ProductPremium] ON;
INSERT INTO [Reference].[ProductPremium] ([Id], [ProductsId], [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes], [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[ProductsId], v.[BasicPremium], v.[BasicPremiumCommission], v.[DJDPatricioMarkup], v.[PartnerMarkup], v.[Discount], v.[Taxes], v.[DST], v.[VAT], v.[LGT], v.[PT], v.[FST], v.[NotarialFee], v.[Others], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, 1, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, 2, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, 3, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, 4, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, 5, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (6, 6, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, 7, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, 8, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (9, 9, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, 10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (11, 11, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (12, 12, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (13, 13, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (14, 14, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (15, 15, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (16, 16, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (17, 17, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (18, 18, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (19, 19, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (20, 20, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (21, 21, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (22, 22, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (23, 23, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (24, 24, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (25, 25, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (26, 26, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (27, 27, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (28, 28, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (29, 29, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (30, 30, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (31, 31, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (32, 32, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (33, 33, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (34, 34, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (35, 35, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (36, 36, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (37, 37, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (38, 38, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (39, 39, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (40, 40, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (41, 41, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (42, 42, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (43, 43, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (44, 44, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (45, 45, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (46, 46, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (47, 47, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (48, 48, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (49, 49, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (50, 50, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (51, 51, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (52, 54, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (53, 55, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (54, 56, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (55, 57, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (56, 58, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (57, 59, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (58, 60, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (59, 61, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (60, 62, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (61, 63, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (62, 64, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (63, 65, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (64, 66, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (65, 67, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (66, 68, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (67, 69, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (68, 70, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (69, 71, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (70, 72, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (71, 73, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (72, 74, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (73, 75, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (74, 76, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (75, 77, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (76, 78, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (77, 79, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (78, 80, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (79, 81, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (80, 82, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (81, 83, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (82, 84, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (83, 85, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (84, 86, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (85, 87, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (86, 88, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (87, 89, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (88, 90, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (89, 91, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (90, 92, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (91, 93, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (92, 94, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (93, 95, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (94, 96, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (95, 97, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (96, 98, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (97, 99, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (98, 100, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (99, 101, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (100, 102, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (101, 103, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (102, 104, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (103, 105, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (104, 106, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (105, 107, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (106, 108, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (107, 109, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (108, 110, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (109, 111, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (110, 112, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (111, 113, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (112, 114, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (113, 115, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (114, 116, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (115, 117, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (116, 118, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (117, 119, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (118, 120, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (119, 121, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (120, 122, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (121, 123, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (122, 124, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (123, 125, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (124, 126, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (125, 127, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (126, 128, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (127, 129, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (128, 130, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (129, 131, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (130, 132, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (131, 133, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (132, 134, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (133, 135, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (134, 136, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (135, 137, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (136, 138, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (137, 139, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (138, 140, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (139, 141, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (140, 142, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (141, 143, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (142, 144, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (143, 145, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (144, 146, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (145, 147, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (146, 148, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (147, 149, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (148, 150, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (149, 151, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (150, 152, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (151, 153, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (152, 154, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [ProductsId], [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes], [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[ProductPremium] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[ProductPremium] OFF;
GO

SET IDENTITY_INSERT [Reference].[Benefits] ON;
INSERT INTO [Reference].[Benefits] ([Id], [Name], [Description], [Code], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[Name], v.[Description], v.[Code], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, N'Accidental Death Benefit', N'Accidental Death Benefit', N'ADB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, N'Accidental Dismemberment and/or Disablement Benefit', N'Accidental Dismemberment and/or Disablement Benefit', N'ADDB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, N'Murder and Unprovoked Assault Benefit', N'Murder and Unprovoked Assault Benefit', N'MUAB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, N'Fire Cash Assistance', N'Fire Cash Assistance', N'FCA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, N'Death Benefit (Accidental or Sickness)', N'Death Benefit (Accidental or Sickness)', N'DB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (6, N'Accident or Sickness Emergency Cash Assistance', N'Accident or Sickness Emergency Cash Assistance', N'ECA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, N'TeleHealth', N'TeleHealth', N'TH', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, N'Life Benefit', N'Life Benefit', N'LIFE', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (9, N'Dengue Cash Assistance', N'Dengue Cash Assistance', N'DCA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, N'ER Maximum Benefit Limit', N'ER Maximum Benefit Limit', N'ERMBL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (11, N'Livelihood Cash Assistance due to Accidental Death', N'Livelihood Cash Assistance due to Accidental Death', N'LHCA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (12, N'Leptos Cash Assistance', N'Leptos Cash Assistance', N'LCA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (13, N'Medicine Reimbursement', N'Medicine Reimbursement', N'MDCR', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (14, N'Hospital Income Benefit', N'Hospital Income Benefit', N'HIB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (15, N'Burial Benefit (Accident)', N'Burial Benefit (Accident)', N'BBA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (16, N'Death Benefit (Dengue)', N'Death Benefit (Dengue)', N'DBD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (17, N'Death Benefit (Chikungunya)', N'Death Benefit (Chikungunya)', N'DBCH', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (18, N'Death Benefit (Covid-19)', N'Death Benefit (Covid-19)', N'DBCV', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (19, N'Hospital Income Benefit (Covid-19)', N'Hospital Income Benefit (Covid-19)', N'HIBCV', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (20, N'Personal Liability', N'Personal Liability', N'PL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (21, N'Motorcycling Coverage', N'Motorcycling Coverage', N'DJDPatricio', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (22, N'Third Party Liability', N'Third Party Liability', N'TPL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (23, N'Medical Reimbursement (Pet Benefit)', N'Medical Reimbursement (Pet Benefit)', N'MRPB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (24, N'Cash Assistance (Food Poisoning)', N'Food Poisoning Cash Assistance', N'FPSN', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (25, N'Total Permanent Disability', N'Total Permanent Disability', N'TPD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (26, N'Accidental Total Permanent Disability', N'Accidental Total Permanent Disability', N'ATPD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (27, N'Elligible days for Hospital Income Benefit', N'Elligible days for Hospital Income Benefit', N'HIBDays', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (28, N'Hospital Income Benefit (Accident)', N'Hospital Income Benefit (Accident)', N'HIBA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (29, N'Elligible days for Hospital Income Benefit (Accident)', N'Elligible days for Hospital Income Benefit (Accident)', N'HIBDayAcc', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (30, N'Medical Reimbursement (Accident)', N'Medical Reimbursement (Accident)', N'MRA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (31, N'Elligible days for Hospital Income Benefit (Covid-19)', N'Elligible days for Hospital Income Benefit (Covid-19)', N'DHIBCV', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (32, N'Accidental Death (Spouse/Parent)', N'Accidental Death (Spouse/Parent)', N'SAD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (33, N'Accidental Dismemberment and/or Disablement Benefit (Spouse/Parent)', N'Accidental Dismemberment and/or Disablement Benefit (Spouse/Parent)', N'SADD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (34, N'Murder and Unprovoked Assault Benefit (Spouse/Parent)', N'Murder and Unprovoked Assault Benefit (Spouse/Parent)', N'SMUA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (35, N'Death Benefit (Spouse/Parent)', N'Death Benefit (Spouse/Parent)', N'SDB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (36, N'Medical Reimbursement (Accident) (Spouse/Parent)', N'Medical Reimbursement (Accident) (Spouse/Parent)', N'SAMR', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (37, N'Accidental Death (Children/Siblings)', N'Accidental Death (Children/Siblings)', N'CAD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (38, N'Accidental Dismemberment and/or Disablement Benefit (Children/Siblings)', N'Accidental Dismemberment and/or Disablement Benefit (Children/Siblings)', N'CADD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (39, N'Murder and Unprovoked Assault Benefit (Children/Siblings)', N'Murder and Unprovoked Assault Benefit (Children/Siblings)', N'CMUA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (40, N'Death Benefit (Children/Siblings)', N'Death Benefit (Children/Siblings)', N'CDB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (41, N'Medical Reimbursement (Accident) (Children/Siblings)', N'Medical Reimbursement (Accident) (Children/Siblings)', N'CAMR', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (42, N'Critical Illness Benefit', N'Critical Illness Benefit', N'CIB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (43, N'Cracked Screen Protection Benefit', N'Cracked Screen Protection Benefit', N'CSP', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (44, N'Accidental Dismemberment and/or Disablement Benefit', N'Accidental Dismemberment and/or Disablement Benefit (Short Scale Benefit)', N'ADDBS', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (45, N'Accidental Dismemberment and/or Disablement Benefit (Spouse/Parent)', N'Accidental Dismemberment and/or Disablement Benefit (Spouse/Parent) (Short Scale Benefit)', N'SADDBS', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (46, N'Accidental Dismemberment and/or Disablement Benefit (Children/Sibling)', N'Accidental Dismemberment and/or Disablement Benefit (Children/Sibling) (Short Scale Benefit)', N'CADDBS', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (47, N'Terrorism Total Permanent Disability', N'Terrorism Total Permanent Disability', N'TTPD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (48, N'Pet Euthanized Death Cash Assistance', N'Pet Euthanized Death Cash Assistance', N'PEDCA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (49, N'Food Poisoning Cash Assistance', N'Food Poisoning Cash Assistance', N'FPCA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (50, N'Mental Health Benefits (Online & Teleconsultation)', N'Mental Health Benefits (Online & Teleconsultation)', N'MHTH', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (51, N'Maximum Benefit Limit', N'Maximum Benefit Limit', N'MBL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (52, N'Surety (Downpayment) Bond', N'Surety (Downpayment) Bond', N'SBND', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (53, N'Bidder’s Bond', N'Bidder’s bond', N'BBND', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (54, N'Performance Bond', N'Performance Bond', N'PBND', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (55, N'Warranty Bond', N'Warranty Bond', N'WBND', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (56, N'Fidelity Bond', N'Fidelity Bond', N'FBND', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (57, N'Heir''s Bond', N'Heir''s Bond', N'HBND', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (58, N'Material Damage', N'Material Damage', N'MADG', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (59, N'Third Party Liability Combined BI PD', N'Third Party Liability Combined BI PD', N'CombinedSingleLimitBIPD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (60, N'Fire and/or Lightning', N'Fire and/or Lightning Only (Property)', N'FL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (61, N'Earthquake', N'Earthquake (Property)', N'EQ', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (62, N'Typhoon', N'Typhoon (Property)', N'TYP', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (63, N'Flood', N'Flood (Property)', N'FLP', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (64, N'Extended Coverage', N'Extended Coverage (Property)', N'ECP', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (65, N'Riot, Strike & Malicious Damage (RSMD)', N'Riot, Strike & Malicious Damage (RSMD) (Property)', N'RSMD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (66, N'Comprehensive General Liability', N'Comprehensive General Liability (Property)', N'CGL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (67, N'Bursting of Water Tanks, Apparatuses & Pipes (BOWTAP)', N'Bursting of Water Tanks, Apparatuses & Pipes (BOWTAP) (Property)', N'BOWTAP', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (68, N'Medical Reimbursement (Accident/Illness)', N'Medical Reimbursement (Accident/Illness)', N'MRCP', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (69, N'Medical Evacuation and Repatriation', N'Medical Evacuation and Repatriation', N'MER', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (70, N'Emergency Dental Care', N'Emergency Dental Care', N'EMDC', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (71, N'Return of a family member traveling with the Insured', N'Return of a family member traveling with the Insured', N'RFMT', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (72, N'Escort of Dependent Child', N'Escort of Dependent Child', N'EDC', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (73, N'Compassionate Visit', N'Compassionate Visit', N'CV', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (74, N'Delayed Departure/Flight', N'Delayed Departure/Flight', N'DDF', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (75, N'Missed Connecting Flights', N'Missed Connecting Flights', N'DJDF', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (76, N'Trip Cancellation', N'Trip Cancellation', N'TCA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (77, N'Trip Curtailment', N'Trip Curtailment', N'TCU', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (78, N'Baggage Delay', N'Baggage Delay', N'BD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (79, N'Loss of Baggage', N'Loss of Baggage', N'LB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (80, N'Hospital Income Benefit (Accident/Illness)', N'Hospital Income Benefit (Accident/Illness)', N'HIBI', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (81, N'Robbery', N'Robbery', N'RB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (82, N'Fraud/Dishonesty', N'Fraud/Dishonesty', N'FOD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (83, N'Robbery / Hold-up', N'Robbery / Hold-up', N'ROH', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (84, N'Own Damage and Theft', N'Own Damage and Theft', N'ODT', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (85, N'Variable Third Party - Bodily Injury', N'Variable Third Party - Bodily Injury', N'VTPBI', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (86, N'Variable Third Party - Property Damage', N'Variable Third Party - Property Damage', N'VTPPD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (87, N'Unnamed Passenger Personal Accident', N'Unnamed Passenger Personal Accident', N'UPPA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (88, N'Additional Unnamed Passenger Personal Accident', N'Additional Unnamed Passenger Personal Accident', N'AUPPA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (89, N'Acts of Nature', N'Acts of Nature', N'AON', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (90, N'Face Amount', N'Face Amount', N'FaceAmount', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (91, N'Accidental Ambulance Benefit', N'Accidental Ambulance Benefit', N'AAB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (92, N'Medical Expenses', N'Covers costs for medical emergencies, including doctor visits, hospital stays, medication, and even emergency dental treatment that may arise due to illness or accidents during your trip.', N'MEDXP', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (93, N'Trip Cancellation and Interruption', N'If your trip is canceled or cut short due to unforeseen circumstances like illness, injury, death of a family member, natural disasters, or even certain travel supplier bankruptcies.', N'TRPCI', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (94, N'Lost, Stolen, or Delayed Baggage', N'Can compensate you for the loss, theft, or damage of your luggage and personal belongings.', N'LSTBG', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (95, N'Travel Delays and Missed Connections', N'Cover additional expenses such as accommodation, meals, and transportation. It can also provide coverage if you miss a connecting flight due to a delay.', N'TRVDY', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (96, N'Personal Liability', N'Protect you if you accidentally cause damage to someone''s property or injure another person during your travels. It can help cover legal costs and compensation you may be required to pay.', N'PERLB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (97, N'Repatriation of Remains', NULL, N'REPRM', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (98, N'Trip Cancellation', NULL, N'TRPCN', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (99, N'Trip Interruption', NULL, N'TRPIN', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (100, N'Baggage Delay', NULL, N'BAGDY', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (101, N'Accidental Death and Dismemberment', NULL, N'ACCTH', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (102, N'Identity Theft Assistance', NULL, N'IDTHF', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (103, N'Hull (Physical Damage)', NULL, N'HULLD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (104, N'Passenger Liability', NULL, N'PASLB', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (105, N'Cargo Liability', NULL, N'CARGL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (106, N'Hangarkeeper''s Liability', NULL, N'HANGR', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (107, N'Ground Risks Hull Coverage', NULL, N'GRNHC', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (108, N'In-Flight Hull Coverage', NULL, N'INFLC', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (109, N'Personal Accident (Crew/Passengers)', NULL, N'PERAC', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (110, N'Spares Coverage', NULL, N'SPARS', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (111, N'Non-Owned Aircraft Liability', NULL, N'NONAL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (112, N'Airport Liability', NULL, N'AIRPT', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (113, N'Products Liability', NULL, N'PRODL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (114, N'Crew Legal Liability', NULL, N'CREWL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (115, N'Search and Rescue Expenses', NULL, N'SRCHR', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (116, N'Data Breach Costs', N'First-Party Coverage', N'DBC', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (117, N'Business Interruption', N'First-Party Coverage', N'BI', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (118, N'Data Recovery and System Restoration', N'First-Party Coverage', N'DRS', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (119, N'Cyber Extortion', N'First-Party Coverage', N'CE', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (120, N'Damage to Digital Assets', N'First-Party Coverage', N'DDA', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (121, N'Fraud and Funds Transfer Loss', N'First-Party Coverage', N'FTL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (122, N'Privacy Liability', N'Third-Party Coverage', N'PRL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (123, N'Network Security Liability', N'Third-Party Coverage', N'NSL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (124, N'Regulatory Defense and Penalties', N'Third-Party Coverage', N'RDP', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (125, N'Media Liability', N'Third-Party Coverage', N'ML', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (126, N'Errors and Omissions (E&O) Coverage', N'Third-Party Coverage', N'EOE', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (127, N'Pre-Incident Support', N'Additional Coverages', N'PIS', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (128, N'Incident Response Services', N'Additional Coverages', N'IRS', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (129, N'Reputation Management', N'Additional Coverages', N'RM', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [Name], [Description], [Code], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[Benefits] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[Benefits] OFF;
GO

SET IDENTITY_INSERT [Reference].[Deductibles] ON;
INSERT INTO [Reference].[Deductibles] ([Id], [Name], [Description], [Code], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[Name], v.[Description], v.[Code], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, N'Material Damage - Other Causes', N'Material Damage - Other Causes', N'MDOC', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, N'Material Damage - Acts of Nature', N'Material Damage - Acts of Nature', N'MDAON', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, N'Third Party Liability - Property Damage Only', N'Third Party Liability - Property Damage Only', N'TPLBIPD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, N'Combined Single Limit BIPD', N'Combined Single Limit BIPD', N'CSLBIPD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, N'Bodily Injury', N'Bodily Injury', N'BODINJ', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (6, N'Property Damage', N'Property Damage', N'PROPD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, N'Food and Drink Liability', N'Food and Drink Liability', N'FDL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, N'Premises Medical Payment', N'Premises Medical Payment', N'PMP', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (9, N'Tenant''s Legal Liability', N'Tenant''s Legal Liability', N'TLL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, N'Inkeepers Liability', N'Inkeepers Liability', N'INKL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (11, N'Contractual Independent Contractors Liability', N'Contractual Independent Contractors Liability', N'CICL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (12, N'Personal Injury', N'Personal Injury', N'PINJ', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (13, N'Fire and/or Lightning', N'Fire and/or Lightning', N'FL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (14, N'Earthquake', N'Earthquake', N'EQ', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (15, N'Typhoon', N'Typhoon', N'TYP', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (16, N'Flood', N'Flood', N'FLP', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (17, N'Extended Coverage', N'Extended Coverage', N'ECP', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (18, N'Riot, Strike & Malicious Damage (RSMD)', N'Riot, Strike & Malicious Damage (RSMD)', N'RSMD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (19, N'Comprehensive General Liability', N'Comprehensive General Liability', N'CGL', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (20, N'Bursting of Water Tanks, Apparatuses & Pipes (BOWTAP)', N'Bursting of Water Tanks, Apparatuses & Pipes (BOWTAP)', N'BOWTAP', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (21, N'Fraud/Dishonesty', N'Fraud/Dishonesty', N'FOD', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (22, N'Robbery / Hold-up', N'Robbery / Hold-up', N'ROH', 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [Name], [Description], [Code], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[Deductibles] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[Deductibles] OFF;
GO

SET IDENTITY_INSERT [Reference].[ProductBenefits] ON;
INSERT INTO [Reference].[ProductBenefits] ([Id], [ProductsId], [BenefitsId], [CoverageAmount], [PremiumAmount], [PremiumCommissionAmount], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[ProductsId], v.[BenefitsId], v.[CoverageAmount], v.[PremiumAmount], v.[PremiumCommissionAmount], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, 1, 1, 20000.00, 7.93, 0.45, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, 1, 2, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, 1, 5, 5000.00, 4.11, 0.45, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, 1, 6, 1000.00, 3.13, 0.45, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, 1, 4, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (6, 1, 3, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, 2, 1, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, 2, 2, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (9, 2, 7, 1.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, 3, 1, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (11, 3, 2, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (12, 3, 4, 2000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (13, 4, 1, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (14, 4, 2, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (15, 4, 5, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (16, 4, 4, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (17, 4, 3, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (18, 5, 1, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (19, 5, 2, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (20, 5, 4, 2000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (21, 6, 1, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (22, 6, 2, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (23, 7, 1, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (24, 7, 2, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (25, 7, 26, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (26, 7, 15, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (27, 7, 4, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (28, 7, 11, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (29, 7, 3, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (30, 8, 1, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (31, 8, 2, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (32, 9, 1, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (33, 9, 2, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (34, 10, 10, 10000.00, 830.72, 0.30, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (35, 11, 10, 20000.00, 1173.19, 0.30, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (36, 12, 10, 5000.00, 488.26, 0.30, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (37, 13, 9, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (38, 14, 1, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (39, 14, 2, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (40, 14, 9, 10000.00, 320.00, 0.20, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (41, 15, 12, 10000.00, 80.00, 0.40, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (42, 16, 10, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (43, 16, 13, 2500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (44, 16, 7, 10.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (45, 17, 13, 2000.00, 537.18, 0.30, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (46, 18, 13, 2500.00, 635.03, 0.30, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (47, 19, 13, 5000.00, 929.55, 0.30, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (48, 20, 7, 10.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (49, 21, 7, 6.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (50, 22, 7, 1000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (51, 23, 9, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (52, 24, 12, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (53, 25, 22, 200000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (54, 26, 22, 200000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (55, 31, 1, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (56, 31, 2, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (57, 31, 5, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (58, 31, 4, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (59, 31, 3, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (60, 32, 1, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (61, 32, 2, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (62, 32, 10, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (63, 32, 14, 300.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (64, 32, 27, 30.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (65, 32, 7, 6.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (66, 33, 1, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (67, 33, 2, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (68, 33, 5, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (69, 33, 7, 6.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (70, 34, 1, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (71, 34, 2, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (72, 34, 26, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (73, 34, 15, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (74, 34, 4, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (75, 34, 11, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (76, 34, 3, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (77, 35, 1, 70000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (78, 35, 2, 70000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (79, 35, 5, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (80, 35, 14, 300.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (81, 35, 27, 31.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (82, 35, 30, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (83, 35, 7, 6.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (84, 36, 1, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (85, 36, 17, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (86, 36, 18, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (87, 36, 16, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (88, 36, 31, 14.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (89, 36, 19, 750.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (90, 36, 30, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (91, 37, 1, 200000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (92, 37, 17, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (93, 37, 18, 200000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (94, 37, 16, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (95, 37, 31, 14.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (96, 37, 19, 1000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (97, 37, 30, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (98, 38, 1, 300000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (99, 38, 17, 150000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (100, 38, 18, 300000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (101, 38, 16, 150000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (102, 38, 31, 14.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (103, 38, 19, 1250.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (104, 38, 30, 37500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (105, 39, 1, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (106, 39, 17, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (107, 39, 18, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (108, 39, 16, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (109, 39, 31, 14.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (110, 39, 19, 750.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (111, 39, 30, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (112, 40, 1, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (113, 40, 17, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (114, 40, 18, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (115, 40, 16, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (116, 40, 31, 14.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (117, 40, 19, 500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (118, 40, 30, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (119, 41, 1, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (120, 41, 17, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (121, 41, 18, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (122, 41, 16, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (123, 41, 31, 14.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (124, 41, 19, 750.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (125, 41, 30, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (126, 42, 1, 200000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (127, 42, 17, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (128, 42, 18, 200000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (129, 42, 16, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (130, 42, 31, 14.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (131, 42, 19, 1000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (132, 42, 30, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (133, 43, 1, 300000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (134, 43, 17, 150000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (135, 43, 18, 300000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (136, 43, 16, 150000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (137, 43, 31, 14.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (138, 43, 19, 1250.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (139, 43, 30, 37500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (140, 44, 1, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (141, 44, 17, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (142, 44, 18, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (143, 44, 16, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (144, 44, 31, 14.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (145, 44, 19, 750.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (146, 44, 30, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (147, 45, 1, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (148, 45, 17, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (149, 45, 18, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (150, 45, 16, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (151, 45, 31, 14.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (152, 45, 19, 500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (153, 45, 30, 12500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (154, 46, 1, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (155, 46, 2, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (156, 47, 1, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (157, 47, 2, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (158, 47, 26, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (159, 47, 23, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (160, 47, 48, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (161, 47, 22, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (162, 48, 22, 200000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (163, 49, 1, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (164, 49, 2, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (165, 49, 37, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (166, 49, 38, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (167, 49, 41, 2500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (168, 49, 40, 2000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (169, 49, 39, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (170, 49, 5, 2500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (171, 49, 30, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (172, 49, 3, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (173, 49, 32, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (174, 49, 33, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (175, 49, 36, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (176, 49, 35, 2000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (177, 49, 34, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (178, 50, 1, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (179, 50, 2, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (180, 50, 10, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (181, 50, 14, 500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (182, 50, 27, 30.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (183, 50, 7, 6.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (184, 51, 1, 1000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (185, 51, 2, 1000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (186, 51, 49, 500.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (187, 54, 1, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (188, 54, 2, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (189, 55, 1, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (190, 55, 2, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (191, 55, 26, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (192, 55, 23, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (193, 55, 48, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (194, 55, 22, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (195, 56, 1, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (196, 56, 2, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (197, 56, 26, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (198, 56, 23, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (199, 56, 48, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (200, 56, 22, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [ProductsId], [BenefitsId], [CoverageAmount], [PremiumAmount], [PremiumCommissionAmount], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[ProductBenefits] AS t WHERE t.[Id] = v.[Id]);
INSERT INTO [Reference].[ProductBenefits] ([Id], [ProductsId], [BenefitsId], [CoverageAmount], [PremiumAmount], [PremiumCommissionAmount], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[ProductsId], v.[BenefitsId], v.[CoverageAmount], v.[PremiumAmount], v.[PremiumCommissionAmount], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (201, 57, 1, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (202, 57, 2, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (203, 57, 26, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (204, 57, 23, 75000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (205, 57, 48, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (206, 57, 22, 75000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (207, 58, 1, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (208, 58, 2, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (209, 58, 26, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (210, 58, 23, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (211, 58, 48, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (212, 58, 22, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (213, 59, 1, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (214, 59, 2, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (215, 59, 15, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (216, 59, 4, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (217, 59, 28, 300.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (218, 59, 29, 30.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (219, 59, 21, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (220, 59, 30, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (221, 59, 3, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (222, 59, 20, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (223, 60, 89, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (224, 60, 88, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (225, 60, 84, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (226, 60, 87, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (227, 60, 85, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (228, 60, 86, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (229, 61, 1, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (230, 61, 2, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (231, 61, 5, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (232, 61, 6, 1000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (233, 61, 25, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (234, 62, 1, 500000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (235, 62, 47, 500000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (236, 63, 1, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (237, 63, 2, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (238, 64, 1, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (239, 64, 2, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (240, 64, 26, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (241, 64, 15, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (242, 64, 4, 1000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (243, 64, 28, 100.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (244, 64, 29, 30.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (245, 64, 30, 3000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (246, 64, 3, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (247, 65, 1, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (248, 65, 2, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (249, 65, 26, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (250, 65, 15, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (251, 65, 28, 300.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (252, 65, 29, 30.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (253, 65, 30, 3000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (254, 65, 3, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (255, 65, 20, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (256, 66, 42, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (257, 67, 5, 200000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (258, 68, 1, 500000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (259, 68, 47, 500000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (260, 69, 1, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (261, 69, 2, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (262, 70, 1, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (263, 70, 2, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (264, 70, 5, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (265, 70, 6, 1000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (266, 70, 25, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (267, 71, 1, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (268, 71, 2, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (269, 72, 1, 20000.00, 23.79, 0.45, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (270, 72, 2, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (271, 72, 5, 10000.00, 12.33, 0.45, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (272, 72, 6, 1500.00, 9.39, 0.45, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (273, 72, 4, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (274, 72, 3, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (275, 73, 1, 20000.00, 7.93, 0.45, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (276, 73, 2, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (277, 73, 5, 10000.00, 4.11, 0.45, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (278, 73, 6, 1500.00, 3.13, 0.45, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (279, 73, 4, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (280, 73, 3, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (281, 74, 1, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (282, 74, 2, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (283, 74, 15, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (284, 74, 4, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (285, 74, 11, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (286, 74, 3, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (287, 74, 7, 1000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (288, 75, 51, 150000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (289, 78, 43, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (290, 79, 43, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (291, 80, 43, 15000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (292, 81, 43, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (293, 82, 43, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (294, 83, 43, 30000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (295, 84, 43, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (296, 85, 43, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (297, 86, 43, 15000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (298, 87, 43, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (299, 88, 43, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (300, 89, 43, 30000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (301, 92, 1, 1500000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (302, 92, 44, 1500000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (303, 92, 37, 250000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (304, 92, 46, 250000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (305, 92, 32, 500000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (306, 92, 45, 500000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (307, 94, 60, 30000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (308, 94, 81, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (309, 95, 1, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (310, 95, 2, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (311, 95, 26, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (312, 95, 15, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (313, 95, 28, 300.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (314, 95, 29, 30.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (315, 95, 30, 3000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (316, 95, 3, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (317, 95, 20, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (318, 101, 1, 1000000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (319, 101, 15, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (320, 101, 78, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (321, 101, 74, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (322, 101, 80, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (323, 101, 79, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (324, 101, 68, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (325, 101, 3, 500000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (326, 101, 76, 150000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (327, 101, 77, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (328, 107, 1, 5000000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (329, 107, 73, 50000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (330, 107, 74, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (331, 107, 72, 5000000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (332, 107, 70, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (333, 107, 75, 10000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (334, 107, 69, 5000000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (335, 107, 68, 5000000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (336, 107, 20, 1500000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (337, 107, 71, 5000000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (338, 107, 76, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (339, 107, 77, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (340, 111, 5, 5000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (341, 111, 6, 2000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (342, 112, 22, 200000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (343, 113, 44, 1000000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (344, 113, 46, 250000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (345, 113, 45, 500000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (346, 114, 5, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (347, 114, 10, 20000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (348, 114, 50, 1000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (349, 116, 52, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (350, 117, 53, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (351, 118, 54, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (352, 119, 55, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (353, 120, 56, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (354, 121, 57, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (355, 122, 59, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (356, 122, 58, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (357, 123, 59, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (358, 123, 58, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (359, 124, 59, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (360, 124, 58, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (361, 125, 58, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (362, 126, 5, 200000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (363, 127, 67, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (364, 127, 66, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (365, 127, 64, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (366, 127, 61, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (367, 127, 60, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (368, 127, 63, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (369, 127, 65, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (370, 127, 62, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (371, 128, 82, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (372, 129, 83, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (373, 130, 1, 100000.00, 200.00, 0.35, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (374, 130, 2, 100000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (375, 130, 4, 25000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (376, 130, 7, 1000.00, 155.00, 0.30, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (377, 131, 90, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (378, 132, 90, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (379, 133, 90, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (380, 134, 101, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (381, 134, 100, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (382, 134, 102, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (383, 134, 94, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (384, 134, 92, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (385, 134, 96, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (386, 134, 97, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (387, 134, 93, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (388, 134, 98, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (389, 134, 99, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (390, 134, 95, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (391, 137, 22, 200000.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (392, 140, 101, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (393, 140, 100, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (394, 140, 102, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (395, 140, 94, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (396, 140, 92, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (397, 140, 96, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (398, 140, 97, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (399, 140, 93, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (400, 140, 98, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [ProductsId], [BenefitsId], [CoverageAmount], [PremiumAmount], [PremiumCommissionAmount], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[ProductBenefits] AS t WHERE t.[Id] = v.[Id]);
INSERT INTO [Reference].[ProductBenefits] ([Id], [ProductsId], [BenefitsId], [CoverageAmount], [PremiumAmount], [PremiumCommissionAmount], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[ProductsId], v.[BenefitsId], v.[CoverageAmount], v.[PremiumAmount], v.[PremiumCommissionAmount], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (401, 140, 99, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (402, 140, 95, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (403, 145, 91, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (404, 145, 2, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (405, 145, 15, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (406, 145, 4, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (407, 145, 29, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (408, 145, 30, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (409, 145, 3, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (410, 146, 2, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (411, 146, 15, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (412, 146, 4, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (413, 146, 29, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (414, 146, 30, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (415, 146, 3, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (416, 146, 25, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (417, 147, 2, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (418, 147, 15, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (419, 147, 4, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (420, 147, 29, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (421, 147, 30, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (422, 147, 3, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (423, 147, 25, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (424, 148, 2, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (425, 148, 15, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (426, 148, 29, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (427, 148, 30, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (428, 148, 3, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (429, 148, 25, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (430, 149, 2, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (431, 149, 15, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (432, 149, 29, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (433, 149, 30, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (434, 149, 3, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (435, 150, 89, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (436, 150, 88, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (437, 150, 84, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (438, 150, 85, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (439, 150, 86, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (440, 151, 66, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (441, 151, 60, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (442, 152, 101, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (443, 152, 100, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (444, 152, 102, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (445, 152, 94, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (446, 152, 92, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (447, 152, 96, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (448, 152, 97, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (449, 152, 93, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (450, 152, 98, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (451, 152, 99, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (452, 152, 95, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (453, 153, 112, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (454, 153, 105, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (455, 153, 114, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (456, 153, 107, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (457, 153, 106, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (458, 153, 103, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (459, 153, 108, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (460, 153, 111, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (461, 153, 104, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (462, 153, 109, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (463, 153, 113, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (464, 153, 110, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (465, 153, 115, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (466, 154, 117, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (467, 154, 119, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (468, 154, 116, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (469, 154, 120, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (470, 154, 118, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (471, 154, 126, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (472, 154, 121, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (473, 154, 128, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (474, 154, 125, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (475, 154, 123, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (476, 154, 127, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (477, 154, 122, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (478, 154, 124, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (479, 154, 129, 0.00, 0.00, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [ProductsId], [BenefitsId], [CoverageAmount], [PremiumAmount], [PremiumCommissionAmount], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[ProductBenefits] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[ProductBenefits] OFF;
GO

SET IDENTITY_INSERT [Reference].[ProductDeductibles] ON;
INSERT INTO [Reference].[ProductDeductibles] ([Id], [ProductsId], [DeductiblesId], [Amount], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[ProductsId], v.[DeductiblesId], v.[Amount], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, 1, 1, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, 1, 2, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, 1, 3, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, 1, 4, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, 1, 5, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (6, 1, 6, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, 1, 7, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, 1, 8, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (9, 1, 9, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, 1, 10, 0.00, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [ProductsId], [DeductiblesId], [Amount], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[ProductDeductibles] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[ProductDeductibles] OFF;
GO

SET IDENTITY_INSERT [Reference].[Partners] ON;
INSERT INTO [Reference].[Partners] ([Id], [Name], [Description], [Code], [ContactPerson], [EmailAddress], [ContactNumber], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[Name], v.[Description], v.[Code], v.[ContactPerson], v.[EmailAddress], v.[ContactNumber], v.[Address1], v.[Address2], v.[AddressTownId], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, N'Sunrise Lending Corp.', N'Microfinance lender specializing in small business loans.', N'SLC01', N'Anna M. Cruz', N'contact@sunriselendingcorp.com', N'+639171234567', N'123 Business St.', NULL, 26397, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, N'Pioneer Insurance Co.', N'Provides affordable microinsurance products to underserved communities.', N'PIC02', N'Carlos R. Mendoza', N'info@pioneerinsuranceco.com', N'+639181234568', N'456 Insurance Ave.', NULL, 28171, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, N'Metro Credit Union', N'Credit union offering loans and savings programs.', N'DJDU03', N'Elena V. Garcia', N'support@metrocreditunion.com', N'+639191234569', N'789 Savings Rd.', NULL, 28710, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, N'Greenfield MFIs', N'Microfinance institution supporting rural entrepreneurs.', N'GFM04', N'Ramon T. Santos', N'contact@greenfieldmfis.com', N'+639201234570', N'234 Rural Rd.', NULL, 28847, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, N'Hope Foundation', N'Non-profit organization providing community support and microloans.', N'HF05', N'Maricel D. Velasco', N'info@hopefoundation.org', N'+639211234571', N'567 Community Ln.', NULL, 28961, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (6, N'Bright Future Microfinance', N'Focused on youth entrepreneurship and financial literacy.', N'BFM06', N'Jorge L. Navarro', N'contact@brightfuturemicrofinance.com', N'+639221234572', N'101 Innovation Blvd.', NULL, 28983, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, N'Solidarity Finance Group', N'Provides group lending and community savings plans.', N'SFG07', N'Liza M. De Leon', N'info@solidarityfinancegroup.com', N'+639231234573', N'202 Unity St.', NULL, 30177, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, N'Unity Microcredit Bank', N'Bank specializing in microloans for small enterprises.', N'UMB08', N'Miguel R. Santos', N'support@unitymicrocreditbank.com', N'+639241234574', N'303 Enterprise Rd.', NULL, 30298, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (9, N'Harmony Microinsurance', N'Offers affordable insurance plans tailored for micro-entrepreneurs.', N'HMI09', N'Sophia P. Reyes', N'contact@harmonymicroinsurance.com', N'+639251234575', N'404 Protection St.', NULL, 31659, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, N'CareLink Foundation', N'Non-profit supporting healthcare microloans and education.', N'CLF10', N'Isabel V. Cruz', N'info@carelinkfoundation.org', N'+639261234576', N'505 Health Ave.', NULL, 32311, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (11, N'Prosperity Finance Corp', N'Offers microloans focused on rural entrepreneurs.', N'PFC11', N'Daniel A. Morales', N'contact@prosperityfinancecorp.com', N'+639271234577', N'606 Progress St.', NULL, 32811, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (12, N'Empower Microfinance', N'Focused on empowering women entrepreneurs through loans and training.', N'EMF12', N'Clara L. Bautista', N'info@empowermicrofinance.com', N'+639281234578', N'707 Hope Blvd.', NULL, 33025, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (13, N'Pioneer Microcredit', N'Supports startups and new micro-businesses with flexible loans.', N'PMC13', N'Ramon C. Diaz', N'support@pioneermicrocredit.com', N'+639291234579', N'808 New Venture Rd.', NULL, 33219, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (14, N'Hope Credit Alliance', N'Alliance offering credit lines and insurance for micro-entrepreneurs.', N'HCA14', N'Maria S. Velasco', N'contact@hopecreditalliance.com', N'+639301234580', N'909 Unity Plaza', NULL, 33764, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (15, N'Unity Trust Microfinance', N'Trust-based microfinance institution supporting local communities.', N'UTM15', N'Carlos D. Navarro', N'info@unitytrustmicrofinance.com', N'+639311234581', N'1001 Trust St.', NULL, 34370, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (16, N'Crestview Microfinance', N'Microfinance provider focusing on agricultural communities.', N'CMF16', N'Elena R. Santos', N'contact@crestviewmicrofinance.com', N'+639321234582', N'1202 Harvest Lane', NULL, 34843, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (17, N'Summit Lending Group', N'Providing flexible loans for small business growth.', N'SLG17', N'Victor M. Reyes', N'info@summitlendinggroup.com', N'+639331234583', N'1303 Mountain View', NULL, 35205, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (18, N'Harbor Microcredit', N'Supports fisherfolk and coastal community entrepreneurs.', N'HMC18', N'Lucia F. dela Cruz', N'support@harbormicrocredit.com', N'+639341234584', N'1404 Bayview St.', NULL, 35372, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (19, N'Greenfield Microfinance', N'Environmentally sustainable microfinance services.', N'GMF19', N'Felipe G. Navarro', N'contact@greenfieldmicrofinance.com', N'+639351234585', N'1505 Greenfield Ave.', NULL, 36602, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (20, N'Silverline Credit Union', N'Credit union supporting artisans and craftsmen.', N'SCU20', N'Anna L. Cruz', N'info@silverlinecreditunion.com', N'+639361234586', N'1606 Artisan Rd.', NULL, 36872, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [Name], [Description], [Code], [ContactPerson], [EmailAddress], [ContactNumber], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[Partners] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[Partners] OFF;
GO

SET IDENTITY_INSERT [Reference].[Providers] ON;
INSERT INTO [Reference].[Providers] ([Id], [Name], [Description], [Code], [ContactPerson], [EmailAddress], [ContactNumber], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[Name], v.[Description], v.[Code], v.[ContactPerson], v.[EmailAddress], v.[ContactNumber], v.[Address1], v.[Address2], v.[AddressTownId], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, N'Metro Health Supplies', N'Supplier of medical and health-related equipment.', N'MHS01', N'Dr. Carl M. Reyes', N'contact@metrohealthsupplies.com', N'+639371234580', N'123 Health Blvd', NULL, 16542, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, N'Bright Pharma Distributors', N'Distributor of pharmaceutical products across regions.', N'BPD02', N'Maria L. Santos', N'info@brightpharma.com', N'+639381234581', N'456 Pharma St.', NULL, 16739, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, N'Evergreen Medical Supplies', N'Providing eco-friendly medical consumables.', N'EMS03', N'Jose R. Delgado', N'support@evergreenmedsupplies.com', N'+639391234582', N'789 Evergreen Rd.', NULL, 16958, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, N'CarePlus Diagnostics', N'Diagnostic equipment and lab services supplier.', N'CPD04', N'Anna G. Villanueva', N'contact@careplusdiagnostics.com', N'+639401234583', N'321 Care St.', NULL, 17763, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, N'Harmony Medical Distributors', N'Supplier of general and specialty medical products.', N'HMD05', N'Ricardo P. Garcia', N'info@harmonymedical.com', N'+639411234584', N'654 Harmony Ave.', NULL, 18624, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (6, N'Prime Medical Equipment', N'Supplier of advanced medical devices and equipment.', N'PME06', N'Liza M. Cruz', N'contact@primemedical.com', N'+639421234585', N'987 Prime St.', NULL, 19573, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, N'HealthPro Solutions', N'Distributor of health and wellness products.', N'HPS07', N'Miguel A. Santos', N'info@healthprosolutions.com', N'+639431234586', N'246 Health Rd.', NULL, 19844, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, N'Medico Pharma Distributors', N'Supplier of pharmaceutical and healthcare products.', N'MPD08', N'Elena V. Reyes', N'support@medicopharma.com', N'+639441234587', N'135 Medico Blvd.', NULL, 21303, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (9, N'WellCare Medical Supplies', N'Provider of medical and wellness supplies.', N'WMS09', N'Juan P. dela Cruz', N'contact@wellcaremedical.com', N'+639451234588', N'357 Wellness St.', NULL, 21378, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, N'CareFirst Medical Distribution', N'Leading supplier of medical devices and consumables.', N'CFM10', N'Anna L. Morales', N'info@carefirstmedical.com', N'+639461234589', N'468 Carefirst Ave.', NULL, 21854, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (11, N'Global Health Supplies', N'International supplier of medical and health products.', N'GHS11', N'Maria R. Santos', N'contact@globalhealthsupplies.com', N'+639471234590', N'789 Global St.', NULL, 22952, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (12, N'MediSource Inc.', N'Distributor of pharmaceutical and medical equipment.', N'MSI12', N'Carlos D. Villanueva', N'info@medisource.com', N'+639481234591', N'123 Medi Lane', NULL, 23301, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (13, N'HealthTech Solutions', N'Supplier of innovative healthcare technologies.', N'HTS13', N'Ana G. Fernandez', N'support@healthtechsolutions.com', N'+639491234592', N'456 Tech Park', NULL, 24081, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (14, N'VitalCare Distributors', N'Reliable supplier of vital care medical products.', N'VCD14', N'Jose M. Cruz', N'contact@vitalcaredist.com', N'+639501234593', N'321 Vital St.', NULL, 25013, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (15, N'MediPlus Supplies', N'Distributor of medical consumables and equipment.', N'MPS15', N'Luisa T. Mendoza', N'info@mediplussupplies.com', N'+639511234594', N'654 Plus Ave.', NULL, 25239, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (16, N'CareFirst Medical', N'Leading provider of healthcare equipment and supplies.', N'CFM16', N'Pedro L. Ramos', N'contact@carefirstmedical.com', N'+639521234595', N'789 Care St.', NULL, 26397, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (17, N'PharmaLink Distributors', N'Supplier of pharmaceutical drugs and medical supplies.', N'PLD17', N'Sonia G. Aquino', N'info@pharmalink.com', N'+639531234596', N'123 Pharma Rd.', NULL, 28171, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (18, N'MedEquip Solutions', N'Provider of advanced medical equipment and tools.', N'MES18', N'Ramon V. Diaz', N'support@medequipsolutions.com', N'+639541234597', N'456 Equip Blvd.', NULL, 28710, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (19, N'Wellness Supplies Inc.', N'Distributor of wellness and healthcare products.', N'WSI19', N'Elena M. Cruz', N'contact@wellnesssupplies.com', N'+639551234598', N'789 Wellness St.', NULL, 28847, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (20, N'HealthPrime Solutions', N'Supplier of premium medical and healthcare equipment.', N'HPS20', N'Daniel P. Garcia', N'info@healthprimesolutions.com', N'+639561234599', N'123 Prime Ave.', NULL, 28961, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [Name], [Description], [Code], [ContactPerson], [EmailAddress], [ContactNumber], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[Providers] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[Providers] OFF;
GO

SET IDENTITY_INSERT [Reference].[Agents] ON;
INSERT INTO [Reference].[Agents] ([Id], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[DJDPatricioOrAgentId], v.[FirstName], v.[MiddleName], v.[LastName], v.[Suffix], v.[EmailAddress], v.[ContactNumber], v.[DateOfBirth], v.[Address1], v.[Address2], v.[AddressTownId], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, N'AGT1011', N'Monica', NULL, N'Reyes', NULL, N'monica.reyes@djdpatricio.com', N'+639171122334', '1991-07-12T00:00:00.0000000', N'123 Greenfield St.', NULL, 37150, 1, NULL, '2026-06-02T10:00:00.0000000', NULL, '2026-06-02T10:00:00.0000000'),
    (2, N'AGT1012', N'Elijah', N'M.', N'Torres', NULL, N'elijah.torres@djdpatricio.com', N'+639178899001', '1985-02-20T00:00:00.0000000', N'45 Sunrise Blvd.', NULL, 37464, 1, NULL, '2026-06-02T10:00:00.0000000', NULL, '2026-06-02T10:00:00.0000000'),
    (3, N'AGT1013', N'Angelica', NULL, N'Velasco', NULL, N'angelica.velasco@djdpatricio.com', N'+639179988776', '1994-10-30T00:00:00.0000000', N'Lot 7 Block 3', N'Camella Homes', 38049, 1, NULL, '2026-06-02T10:00:00.0000000', NULL, '2026-06-02T10:00:00.0000000'),
    (4, N'AGT1014', N'Ramon', N'L.', N'Castillo', N'Jr.', N'ramon.castillo@djdpatricio.com', N'+639176655443', '1979-12-05T00:00:00.0000000', N'85 Oakwood Ave.', NULL, 38703, 1, NULL, '2026-06-02T10:00:00.0000000', NULL, '2026-06-02T10:00:00.0000000'),
    (5, N'AGT1015', N'Leah', NULL, N'Marquez', NULL, N'leah.marquez@djdpatricio.com', N'+639172233445', '1990-09-18T00:00:00.0000000', N'Unit 15, Blue Ridge', N'Green Meadows', 39078, 1, NULL, '2026-06-02T10:00:00.0000000', NULL, '2026-06-02T10:00:00.0000000')
) AS v ([Id], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[Agents] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[Agents] OFF;
GO

SET IDENTITY_INSERT [Reference].[Approvers] ON;
INSERT INTO [Reference].[Approvers] ([Id], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[DJDPatricioOrAgentId], v.[FirstName], v.[MiddleName], v.[LastName], v.[Suffix], v.[EmailAddress], v.[ContactNumber], v.[DateOfBirth], v.[Address1], v.[Address2], v.[AddressTownId], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, N'AGT1006', N'Carlos', N'Emmanuel', N'Mendoza', NULL, N'carlos.mendoza@gmail.com', N'+639176782345', '1987-03-19T00:00:00.0000000', N'45 Sta. Rosa Road', N'Nuvali Heights', 3814, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, N'AGT1007', N'Jasmine', NULL, N'Flores', NULL, N'jasmine.flores@djdpatricio.com', N'+639181234987', '1996-11-08T00:00:00.0000000', N'Blk 6 Lot 20', N'Palm Grove Subd.', 3962, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, N'AGT1008', N'Nathan', N'Oliver', N'Gutierrez', N'III', N'nathan.gutierrez@djdpatricio.com', N'+639192224466', '1989-06-25T00:00:00.0000000', N'Purok 7', NULL, 4082, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, N'AGT1009', N'Patricia', N'Ysobel', N'Del Rosario', NULL, N'patricia.delrosario@djdpatricio.com', N'+639175551234', '1993-01-17T00:00:00.0000000', N'Zone 3', N'Sitio Kabilang Bakod', 10258, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, N'AGT1010', N'Jericho', N'Benedict', N'Salvador', N'Sr.', N'jericho.salvador@djdpatricio.com', N'+639184447788', '1980-08-03T00:00:00.0000000', N'#12 Sunset Blvd', N'Tierra Verde', 10345, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[Approvers] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[Approvers] OFF;
GO

SET IDENTITY_INSERT [Reference].[SubAgents] ON;
INSERT INTO [Reference].[SubAgents] ([Id], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[DJDPatricioOrAgentId], v.[FirstName], v.[MiddleName], v.[LastName], v.[Suffix], v.[EmailAddress], v.[ContactNumber], v.[DateOfBirth], v.[Address1], v.[Address2], v.[AddressTownId], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, N'AGT1011', N'Monica', NULL, N'Reyes', NULL, N'monica.reyes@djdpatricio.com', N'+639171122334', '1991-07-12T00:00:00.0000000', N'123 Greenfield St.', NULL, 37150, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, N'AGT1012', N'Elijah', N'M.', N'Torres', NULL, N'elijah.torres@djdpatricio.com', N'+639178899001', '1985-02-20T00:00:00.0000000', N'45 Sunrise Blvd.', NULL, 37464, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, N'AGT1013', N'Angelica', NULL, N'Velasco', NULL, N'angelica.velasco@djdpatricio.com', N'+639179988776', '1994-10-30T00:00:00.0000000', N'Lot 7 Block 3', N'Camella Homes', 38049, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, N'AGT1014', N'Ramon', N'L.', N'Castillo', N'Jr.', N'ramon.castillo@djdpatricio.com', N'+639176655443', '1979-12-05T00:00:00.0000000', N'85 Oakwood Ave.', NULL, 38703, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, N'AGT1015', N'Leah', NULL, N'Marquez', NULL, N'leah.marquez@djdpatricio.com', N'+639172233445', '1990-09-18T00:00:00.0000000', N'Unit 15, Blue Ridge', N'Green Meadows', 39078, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[SubAgents] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[SubAgents] OFF;
GO

SET IDENTITY_INSERT [Reference].[PromoManagers] ON;
INSERT INTO [Reference].[PromoManagers] ([Id], [AgentsId], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[AgentsId], v.[DJDPatricioOrAgentId], v.[FirstName], v.[MiddleName], v.[LastName], v.[Suffix], v.[EmailAddress], v.[ContactNumber], v.[DateOfBirth], v.[Address1], v.[Address2], v.[AddressTownId], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, 1, N'AGT031', N'Carlos', N'R', N'Reyes', NULL, N'carlos.reyes@djdpatricio.com', N'+639151234567', '1987-03-15T00:00:00.0000000', N'654 Mango St.', N'Blk 7 Lot 2', 37150, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, 1, N'AGT032', N'Jessa', NULL, N'Torres', N'Jr.', N'jessa.torres@djdpatricio.com', N'+639178765432', '1990-11-09T00:00:00.0000000', N'789 Pine Rd.', N'Lot 14', 37464, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, 1, N'AGT033', N'Mark', N'L', N'Valdez', NULL, N'mark.valdez@djdpatricio.com', N'+639189012345', '1982-06-22T00:00:00.0000000', N'321 Elm St.', NULL, 38049, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, 2, N'AGT034', N'Leah', N'M', N'Garcia', NULL, N'leah.garcia@djdpatricio.com', N'+639173456789', '1994-02-10T00:00:00.0000000', N'432 Birch St.', N'Apt 101', 38703, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, 2, N'AGT035', N'David', NULL, N'Luna', N'III', N'david.luna@djdpatricio.com', N'+639177654321', '1980-08-25T00:00:00.0000000', N'987 Spruce Rd.', NULL, 39078, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (6, 2, N'AGT036', N'Maria', N'C', N'Delgado', NULL, N'maria.delgado@djdpatricio.com', N'+639170123456', '1992-12-01T00:00:00.0000000', N'213 Cedar Ln.', N'Unit 3', 39464, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, 3, N'AGT037', N'Joseph', N'T', N'Salazar', NULL, N'joseph.salazar@djdpatricio.com', N'+639182345678', '1988-05-05T00:00:00.0000000', N'345 Willow Dr.', NULL, 39769, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, 3, N'AGT038', N'Angela', NULL, N'Castillo', NULL, N'angela.castillo@djdpatricio.com', N'+639179876543', '1995-09-30T00:00:00.0000000', N'876 Maple St.', NULL, 40245, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (9, 3, N'AGT039', N'Samuel', N'V', N'Flores', NULL, N'samuel.flores@djdpatricio.com', N'+639171234987', '1983-04-14T00:00:00.0000000', N'654 Oak Ln.', N'Suite 4B', 41083, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, 4, N'AGT040', N'Patricia', NULL, N'Morales', NULL, N'patricia.morales@djdpatricio.com', N'+639174567890', '1991-07-19T00:00:00.0000000', N'109 Chestnut Rd.', NULL, 41457, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (11, 4, N'AGT041', N'Erwin', N'D', N'Navarro', NULL, N'erwin.navarro@djdpatricio.com', N'+639178909876', '1986-01-27T00:00:00.0000000', N'231 Aspen Dr.', NULL, 41680, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (12, 4, N'AGT042', N'Cynthia', N'L', N'Salvador', N'Sr.', N'cynthia.salvador@djdpatricio.com', N'+639179012345', '1993-10-12T00:00:00.0000000', N'567 Fir St.', N'Apt 5A', 1126, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (13, 5, N'AGT043', N'Brian', N'F', N'Dela Cruz', NULL, N'brian.delacruz@djdpatricio.com', N'+639171098765', '1989-11-03T00:00:00.0000000', N'890 Redwood Ave.', NULL, 1304, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (14, 5, N'AGT044', N'Monica', NULL, N'Villar', NULL, N'monica.villar@djdpatricio.com', N'+639172345678', '1996-06-07T00:00:00.0000000', N'432 Cypress St.', NULL, 3081, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (15, 5, N'AGT045', N'Rafael', N'S', N'Mendoza', NULL, N'rafael.mendoza@djdpatricio.com', N'+639176543210', '1984-03-29T00:00:00.0000000', N'210 Sequoia Blvd.', N'Suite 10', 3625, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [AgentsId], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[PromoManagers] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[PromoManagers] OFF;
GO

SET IDENTITY_INSERT [Reference].[PromoOfficers] ON;
INSERT INTO [Reference].[PromoOfficers] ([Id], [AgentsId], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[AgentsId], v.[DJDPatricioOrAgentId], v.[FirstName], v.[MiddleName], v.[LastName], v.[Suffix], v.[EmailAddress], v.[ContactNumber], v.[DateOfBirth], v.[Address1], v.[Address2], v.[AddressTownId], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, 1, N'AGT1016', N'Evelyn', NULL, N'Santos', NULL, N'evelyn.santos@djdpatricio.com', N'+639171234001', '1988-05-10T00:00:00.0000000', N'123 Liberty St.', NULL, 3681, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (2, 1, N'AGT1017', N'Marco', N'D.', N'Lopez', NULL, N'marco.lopez@djdpatricio.com', N'+639178899002', '1992-11-20T00:00:00.0000000', N'456 Pine St.', NULL, 3814, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (3, 1, N'AGT1018', N'Diana', NULL, N'Morales', N'Jr.', N'diana.morales@djdpatricio.com', N'+639172255009', '1985-01-03T00:00:00.0000000', N'789 Oak St.', NULL, 3962, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, 2, N'AGT1019', N'Ricardo', N'L.', N'Garcia', NULL, N'ricardo.garcia@djdpatricio.com', N'+639177766554', '1990-06-15T00:00:00.0000000', N'12 Maple St.', NULL, 4082, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, 2, N'AGT1020', N'Nina', NULL, N'Villar', NULL, N'nina.villar@djdpatricio.com', N'+639179912345', '1995-09-22T00:00:00.0000000', N'34 Garden St.', NULL, 10258, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (6, 2, N'AGT1021', N'Alfred', N'G.', N'Torres', N'Sr.', N'alfred.torres@djdpatricio.com', N'+639174411223', '1983-03-09T00:00:00.0000000', N'56 Lakeview Dr.', NULL, 10345, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, 3, N'AGT1022', N'Bianca', NULL, N'Delgado', NULL, N'bianca.delgado@djdpatricio.com', N'+639175533221', '1991-12-12T00:00:00.0000000', N'89 Rose St.', NULL, 11209, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, 3, N'AGT1023', N'Jorge', N'M.', N'Ramos', NULL, N'jorge.ramos@djdpatricio.com', N'+639178833221', '1987-08-19T00:00:00.0000000', N'22 Hill St.', NULL, 11844, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (9, 3, N'AGT1024', N'Samantha', NULL, N'Ortiz', NULL, N'samantha.ortiz@djdpatricio.com', N'+639172244556', '1993-04-23T00:00:00.0000000', N'101 Sunrise St.', NULL, 12750, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, 4, N'AGT1025', N'Daniel', NULL, N'Navarro', NULL, N'daniel.navarro@djdpatricio.com', N'+639176677889', '1986-07-11T00:00:00.0000000', N'303 Elm St.', NULL, 13559, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (11, 4, N'AGT1026', N'Vanessa', N'T.', N'Salazar', NULL, N'vanessa.salazar@djdpatricio.com', N'+639179922334', '1990-02-27T00:00:00.0000000', N'400 Pine St.', NULL, 14108, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (12, 4, N'AGT1027', N'Emilio', NULL, N'Diaz', NULL, N'emilio.diaz@djdpatricio.com', N'+639178855443', '1984-03-15T00:00:00.0000000', N'55 Cedar St.', NULL, 14502, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (13, 5, N'AGT1028', N'Gloria', NULL, N'Mendoza', NULL, N'gloria.mendoza@djdpatricio.com', N'+639172266778', '1992-09-09T00:00:00.0000000', N'22 Park Ave.', NULL, 14624, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (14, 5, N'AGT1029', N'Hector', N'J.', N'Reyes', NULL, N'hector.reyes@djdpatricio.com', N'+639177711223', '1987-01-05T00:00:00.0000000', N'88 Sunset Blvd.', NULL, 15838, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (15, 5, N'AGT1030', N'Isabel', NULL, N'Torres', NULL, N'isabel.torres@djdpatricio.com', N'+639175599112', '1994-11-14T00:00:00.0000000', N'10 Maple St.', NULL, 16453, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [AgentsId], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[PromoOfficers] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[PromoOfficers] OFF;
GO

SET IDENTITY_INSERT [Reference].[SalesManagers] ON;
INSERT INTO [Reference].[SalesManagers] ([Id], [AgentsId], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[AgentsId], v.[DJDPatricioOrAgentId], v.[FirstName], v.[MiddleName], v.[LastName], v.[Suffix], v.[EmailAddress], v.[ContactNumber], v.[DateOfBirth], v.[Address1], v.[Address2], v.[AddressTownId], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (3, 1, N'AGT046', N'Angelica', N'S', N'Torres', NULL, N'angelica.torres@djdpatricio.com', N'+639178123456', '1991-05-18T00:00:00.0000000', N'45 Palm St.', NULL, 28983, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (4, 1, N'AGT047', N'Jonathan', NULL, N'Reyes', N'Jr.', N'jonathan.reyes@djdpatricio.com', N'+639175678901', '1987-08-22T00:00:00.0000000', N'120 Oak St.', N'Blk 9 Lot 3', 30177, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (5, 1, N'AGT048', N'Beatrice', N'M', N'Delgado', NULL, N'beatrice.delgado@djdpatricio.com', N'+639179876234', '1990-12-05T00:00:00.0000000', N'33 Maple Ave.', NULL, 30298, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (6, 2, N'AGT049', N'Ernest', N'L', N'Castillo', NULL, N'ernest.castillo@djdpatricio.com', N'+639170987654', '1982-03-15T00:00:00.0000000', N'78 Birch Rd.', N'Apt 201', 31659, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, 2, N'AGT050', N'Jessica', NULL, N'Flores', NULL, N'jessica.flores@djdpatricio.com', N'+639171234890', '1994-07-29T00:00:00.0000000', N'56 Cedar St.', NULL, 32311, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, 2, N'AGT051', N'Roland', N'A', N'Navarro', NULL, N'roland.navarro@djdpatricio.com', N'+639178901234', '1986-11-10T00:00:00.0000000', N'94 Pine Ln.', N'Unit 7', 32811, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (9, 3, N'AGT052', N'Sophia', N'G', N'Morales', NULL, N'sophia.morales@djdpatricio.com', N'+639172345109', '1993-04-21T00:00:00.0000000', N'87 Elm Dr.', NULL, 33025, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, 3, N'AGT053', N'Miguel', NULL, N'Luna', NULL, N'miguel.luna@djdpatricio.com', N'+639179876019', '1980-09-07T00:00:00.0000000', N'15 Redwood St.', NULL, 33219, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (11, 3, N'AGT054', N'Nina', N'T', N'Salvador', N'III', N'nina.salvador@djdpatricio.com', N'+639173456210', '1991-01-30T00:00:00.0000000', N'48 Spruce Blvd.', N'Suite 12', 33764, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (12, 4, N'AGT055', N'Jason', N'B', N'Dela Cruz', NULL, N'jason.delacruz@djdpatricio.com', N'+639170987321', '1989-06-15T00:00:00.0000000', N'62 Cypress Rd.', NULL, 34370, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (13, 4, N'AGT056', N'Rhea', NULL, N'Villar', NULL, N'rhea.villar@djdpatricio.com', N'+639174321987', '1996-10-22T00:00:00.0000000', N'110 Chestnut Ave.', NULL, 34843, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (14, 4, N'AGT057', N'Daniel', N'M', N'Mendoza', NULL, N'daniel.mendoza@djdpatricio.com', N'+639178654321', '1984-02-18T00:00:00.0000000', N'27 Fir St.', N'Apt 8C', 35205, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (15, 5, N'AGT058', N'Camille', N'R', N'Garcia', NULL, N'camille.garcia@djdpatricio.com', N'+639171234098', '1992-03-25T00:00:00.0000000', N'59 Willow Dr.', NULL, 35372, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (16, 5, N'AGT059', N'Francis', NULL, N'Salazar', NULL, N'francis.salazar@djdpatricio.com', N'+639179876543', '1988-12-14T00:00:00.0000000', N'101 Maple Ln.', N'Suite 2B', 36602, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (17, 5, N'AGT060', N'Olivia', N'L', N'Castillo', NULL, N'olivia.castillo@djdpatricio.com', N'+639170987654', '1990-07-09T00:00:00.0000000', N'85 Pine St.', NULL, 36872, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [AgentsId], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[SalesManagers] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[SalesManagers] OFF;
GO

SET IDENTITY_INSERT [Reference].[Clients] ON;
INSERT INTO [Reference].[Clients] ([Id], [InsuranceCustomerNo], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [IsMale], [ValidIdPresented], [ValidIdPresentedNumber], [ValidIdExpiration], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[InsuranceCustomerNo], v.[FirstName], v.[MiddleName], v.[LastName], v.[Suffix], v.[EmailAddress], v.[ContactNumber], v.[DateOfBirth], v.[IsMale], v.[ValidIdPresented], v.[ValidIdPresentedNumber], v.[ValidIdExpiration], v.[Address1], v.[Address2], v.[AddressTownId], v.[IsActive], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (6, N'INSC123456', N'Juan', N'M', N'Dela Cruz', NULL, N'juan.delacruz@gmail.com', N'+639171234567', '1985-04-15T00:00:00.0000000', 1, 1, N'DL123456789', '2027-04-14T00:00:00.0000000', N'123 Mabini St.', NULL, 11209, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (7, N'INSC123457', N'Maria', N'L', N'Santos', N'Jr.', N'maria.santos@gmail.com', N'+639181234568', '1990-09-30T00:00:00.0000000', 0, 2, N'P1234567', '2030-09-29T00:00:00.0000000', N'456 Mabini Ave.', NULL, 11844, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (8, N'INSC123458', N'Carlos', NULL, N'Reyes', NULL, N'carlos.reyes@gmail.com', N'+639191234569', '1978-12-05T00:00:00.0000000', 1, 3, N'SSS987654321', '2028-12-04T00:00:00.0000000', N'789 Mabini Blvd.', NULL, 12750, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (9, N'INSC123459', N'Ana', N'P', N'Garcia', NULL, N'ana.garcia@gmail.com', N'+639201234570', '1982-07-20T00:00:00.0000000', 0, 4, N'UMID11223344', '2026-07-19T00:00:00.0000000', N'101 Mabini Rd.', NULL, 13559, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (10, N'INSC123460', N'Jose', N'R', N'Torres', NULL, N'jose.torres@gmail.com', N'+639211234571', '1975-11-11T00:00:00.0000000', 1, 5, N'VOTER7654321', '2025-11-10T00:00:00.0000000', N'202 Mabini St.', NULL, 14108, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (11, N'INSC123461', N'Luz', N'D', N'Velasco', NULL, N'luz.velasco@gmail.com', N'+639221234572', '1988-02-18T00:00:00.0000000', 0, 6, N'PH123456789', '2029-02-17T00:00:00.0000000', N'303 Mabini St.', NULL, 14502, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (12, N'INSC123462', N'Ramon', NULL, N'Mendoza', NULL, N'ramon.mendoza@gmail.com', N'+639231234573', '1972-10-03T00:00:00.0000000', 1, 3, N'SSS123987456', '2027-10-02T00:00:00.0000000', N'404 Mabini Ave.', NULL, 14624, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (13, N'INSC123463', N'Gloria', N'S', N'Lopez', NULL, N'gloria.lopez@gmail.com', N'+639241234574', '1980-06-12T00:00:00.0000000', 0, 2, N'P987654321', '2031-06-11T00:00:00.0000000', N'505 Mabini Rd.', NULL, 15838, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (14, N'INSC123464', N'Pedro', N'M', N'Cruz', NULL, N'pedro.cruz@gmail.com', N'+639251234575', '1979-01-25T00:00:00.0000000', 1, 5, N'VOTER654321', '2026-01-24T00:00:00.0000000', N'606 Mabini St.', NULL, 16453, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (15, N'INSC123465', N'Elena', NULL, N'Gomez', NULL, N'elena.gomez@gmail.com', N'+639261234576', '1987-03-17T00:00:00.0000000', 0, 4, N'UMID998877', '2028-03-16T00:00:00.0000000', N'707 Mabini Ave.', NULL, 16542, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (16, N'INSC123466', N'Juan', N'P', N'Reyes', NULL, N'juan.reyes@gmail.com', N'+639271234577', '1983-07-21T00:00:00.0000000', 1, 1, N'DL987654321', '2029-07-20T00:00:00.0000000', N'808 Mabini St.', NULL, 16739, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (17, N'INSC123467', N'Maria', NULL, N'Del Rosario', NULL, N'maria.delrosario@gmail.com', N'+639281234578', '1990-12-05T00:00:00.0000000', 0, 2, N'P123456789', '2030-12-04T00:00:00.0000000', N'909 Mabini Ave.', NULL, 16958, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (19, N'INSC123469', N'Ana', N'M', N'Torres', NULL, N'ana.torres@gmail.com', N'+639301234580', '1985-09-29T00:00:00.0000000', 0, 4, N'UMID654321987', '2028-09-28T00:00:00.0000000', N'1111 Mabini St.', NULL, 17763, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (20, N'INSC123470', N'Jose', NULL, N'Garcia', NULL, N'jose.garcia@gmail.com', N'+639311234581', '1978-05-14T00:00:00.0000000', 1, 5, N'VOTER123654', '2026-05-13T00:00:00.0000000', N'1212 Mabini Ave.', NULL, 18624, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (21, N'INSC123471', N'Lucia', N'F', N'Velasco', NULL, N'lucia.velasco@gmail.com', N'+639321234582', '1992-03-08T00:00:00.0000000', 0, 6, N'PH123456789', '2031-03-07T00:00:00.0000000', N'1234 Rizal St.', NULL, 19573, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (22, N'INSC123472', N'Ramon', N'S', N'Lopez', NULL, N'ramon.lopez@gmail.com', N'+639331234583', '1988-10-25T00:00:00.0000000', 1, 1, N'DL654987321', '2029-10-24T00:00:00.0000000', N'4321 Mabini Blvd.', NULL, 19844, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (23, N'INSC123473', N'Ella', NULL, N'Gonzales', NULL, N'ella.gonzales@gmail.com', N'+639341234584', '1995-06-19T00:00:00.0000000', 0, 2, N'P987654321', '2030-06-18T00:00:00.0000000', N'5678 Mabini St.', NULL, 21303, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (24, N'INSC123474', N'Marco', N'L', N'De Guzman', NULL, N'marco.deguzman@gmail.com', N'+639351234585', '1982-04-12T00:00:00.0000000', 1, 3, N'SSS321654987', '2027-04-11T00:00:00.0000000', N'7890 Mabini Rd.', NULL, 21378, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (25, N'INSC123475', N'Isabel', N'T', N'Morales', NULL, N'isabel.morales@gmail.com', N'+639361234586', '1991-11-03T00:00:00.0000000', 0, 4, N'UMID789123456', '2028-11-02T00:00:00.0000000', N'2345 Mabini Ave.', NULL, 21854, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (26, N'INSC123476', N'Pedro', NULL, N'Martinez', NULL, N'pedro.martinez@gmail.com', N'+639371234587', '1979-08-17T00:00:00.0000000', 1, 5, N'VOTER987654', '2026-08-16T00:00:00.0000000', N'3456 Mabini St.', NULL, 22952, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (27, N'INSC123477', N'Carla', N'M', N'Reyes', NULL, N'carla.reyes@gmail.com', N'+639381234588', '1993-02-14T00:00:00.0000000', 0, 1, N'DL789654321', '2030-02-13T00:00:00.0000000', N'5678 Luna St.', NULL, 23301, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (28, N'INSC123478', N'Diego', NULL, N'Salazar', NULL, N'diego.salazar@gmail.com', N'+639391234589', '1987-07-22T00:00:00.0000000', 1, 2, N'P123789456', '2028-07-21T00:00:00.0000000', N'4321 Mabini Blvd.', NULL, 24081, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (29, N'INSC123479', N'Francesca', N'L', N'Dela Cruz', NULL, N'francesca.delacruz@gmail.com', N'+639401234590', '1990-05-30T00:00:00.0000000', 0, 3, N'SSS654321987', '2029-05-29T00:00:00.0000000', N'1234 Mabini St.', NULL, 25013, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000'),
    (30, N'INSC123480', N'Hector', NULL, N'Gomez', N'Jr.', N'hector.gomez@gmail.com', N'+639411234591', '1985-12-01T00:00:00.0000000', 1, 4, N'UMID321987654', '2027-11-30T00:00:00.0000000', N'9876 Mabini Rd.', NULL, 25239, 1, NULL, '2025-06-02T00:00:00.0000000', NULL, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [InsuranceCustomerNo], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [IsMale], [ValidIdPresented], [ValidIdPresentedNumber], [ValidIdExpiration], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[Clients] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Reference].[Clients] OFF;
GO

SET IDENTITY_INSERT [Transaction].[IndividualPolicy] ON;
INSERT INTO [Transaction].[IndividualPolicy] ([Id], [ReferenceNumber], [CocNumber], [ClientsId], [PartnersId], [PlatformsId], [IssueStatus], [PolicyBookingStatusId], [CocStatusId], [PaymentStatusId], [ClaimsStatusId], [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId], [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId], [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks], [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes], [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[ReferenceNumber], v.[CocNumber], v.[ClientsId], v.[PartnersId], v.[PlatformsId], v.[IssueStatus], v.[PolicyBookingStatusId], v.[CocStatusId], v.[PaymentStatusId], v.[ClaimsStatusId], v.[AgentsId], v.[SubAgentsId], v.[ApproversId], v.[PromoManagersId], v.[SalesManagersId], v.[PromoOfficersId], v.[ProductsId], v.[ProvidersId], v.[DistributionChannelId], v.[PaymentOptionId], v.[ProviderPolicyNo], v.[EndorsementNo], v.[TerminationDate], v.[EffectiveDate], v.[IssueDate], v.[Remarks], v.[BasicPremium], v.[BasicPremiumCommission], v.[DJDPatricioMarkup], v.[PartnerMarkup], v.[Discount], v.[Taxes], v.[DST], v.[VAT], v.[LGT], v.[PT], v.[FST], v.[NotarialFee], v.[Others], v.[PremiumsRemarks], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, N'IPB000000001', N'000000000004', 26, 5, 27, 1, 3, 1, 1, 3, 1, 2, 3, NULL, NULL, NULL, 1, 11, 4, 27, N'PPN-IMS3-001', N'EN-IMS3-004', '2026-06-07T00:00:00.0000000', '2025-06-07T00:00:00.0000000', '2025-06-07T00:00:00.0000000', N'Remarks', 10, 20, 30, 40, 130, 50, 60, 70, 80, 90, 100, 110, 120, N'Premium Remarks', 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (2, N'IPB000000002', N'000000000005', 26, 5, 27, 1, 3, 1, 1, 3, 1, NULL, 3, 1, 3, 2, 1, 11, 7, 27, N'PPN-IMS3-001', N'EN-IMS3-005', '2026-06-07T00:00:00.0000000', '2025-06-07T00:00:00.0000000', '2025-06-07T00:00:00.0000000', N'Remarks', 10, 20, 30, 40, 130, 50, 60, 70, 80, 90, 100, 110, 120, N'Premium Remarks', 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [ReferenceNumber], [CocNumber], [ClientsId], [PartnersId], [PlatformsId], [IssueStatus], [PolicyBookingStatusId], [CocStatusId], [PaymentStatusId], [ClaimsStatusId], [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId], [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId], [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks], [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes], [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Transaction].[IndividualPolicy] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Transaction].[IndividualPolicy] OFF;
GO

SET IDENTITY_INSERT [Transaction].[PartnerPolicy] ON;
INSERT INTO [Transaction].[PartnerPolicy] ([Id], [ReferenceNumber], [CocNumber], [PartnersId], [PlatformsId], [IssueStatus], [PolicyBookingStatusId], [CocStatusId], [PaymentStatusId], [ClaimsStatusId], [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId], [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId], [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks], [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes], [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[ReferenceNumber], v.[CocNumber], v.[PartnersId], v.[PlatformsId], v.[IssueStatus], v.[PolicyBookingStatusId], v.[CocStatusId], v.[PaymentStatusId], v.[ClaimsStatusId], v.[AgentsId], v.[SubAgentsId], v.[ApproversId], v.[PromoManagersId], v.[SalesManagersId], v.[PromoOfficersId], v.[ProductsId], v.[ProvidersId], v.[DistributionChannelId], v.[PaymentOptionId], v.[ProviderPolicyNo], v.[EndorsementNo], v.[TerminationDate], v.[EffectiveDate], v.[IssueDate], v.[Remarks], v.[BasicPremium], v.[BasicPremiumCommission], v.[DJDPatricioMarkup], v.[PartnerMarkup], v.[Discount], v.[Taxes], v.[DST], v.[VAT], v.[LGT], v.[PT], v.[FST], v.[NotarialFee], v.[Others], v.[PremiumsRemarks], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, N'PPB000000001', N'000000000006', 5, 27, 1, 3, 1, 1, 3, 1, NULL, 3, 1, 3, 2, 1, 11, 7, 27, N'PPN-IMS3-001', N'EN-IMS3-006', '2026-06-07T00:00:00.0000000', '2025-06-07T00:00:00.0000000', '2025-06-07T00:00:00.0000000', N'Remarks', 10, 20, 30, 40, 130, 50, 60, 70, 80, 90, 100, 110, 120, N'Premium Remarks', 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (2, N'PPB000000002', N'000000000007', 5, 27, 1, 3, 1, 1, 3, 1, 2, 3, NULL, NULL, NULL, 1, 11, 4, 27, N'PPN-IMS3-001', N'EN-IMS3-007', '2026-06-07T00:00:00.0000000', '2025-06-07T00:00:00.0000000', '2025-06-07T00:00:00.0000000', N'Remarks', 10, 20, 30, 40, 130, 50, 60, 70, 80, 90, 100, 110, 120, N'Premium Remarks', 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [ReferenceNumber], [CocNumber], [PartnersId], [PlatformsId], [IssueStatus], [PolicyBookingStatusId], [CocStatusId], [PaymentStatusId], [ClaimsStatusId], [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId], [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId], [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks], [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes], [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Transaction].[PartnerPolicy] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Transaction].[PartnerPolicy] OFF;
GO

SET IDENTITY_INSERT [Transaction].[GroupPolicy] ON;
INSERT INTO [Transaction].[GroupPolicy] ([Id], [ReferenceNumber], [CocNumber], [PartnersId], [PlatformsId], [IssueStatus], [PolicyBookingStatusId], [CocStatusId], [PaymentStatusId], [ClaimsStatusId], [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId], [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId], [AccountTypeId], [BranchCode], [BranchName], [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks], [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes], [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[ReferenceNumber], v.[CocNumber], v.[PartnersId], v.[PlatformsId], v.[IssueStatus], v.[PolicyBookingStatusId], v.[CocStatusId], v.[PaymentStatusId], v.[ClaimsStatusId], v.[AgentsId], v.[SubAgentsId], v.[ApproversId], v.[PromoManagersId], v.[SalesManagersId], v.[PromoOfficersId], v.[ProductsId], v.[ProvidersId], v.[DistributionChannelId], v.[PaymentOptionId], v.[AccountTypeId], v.[BranchCode], v.[BranchName], v.[ProviderPolicyNo], v.[EndorsementNo], v.[TerminationDate], v.[EffectiveDate], v.[IssueDate], v.[Remarks], v.[BasicPremium], v.[BasicPremiumCommission], v.[DJDPatricioMarkup], v.[PartnerMarkup], v.[Discount], v.[Taxes], v.[DST], v.[VAT], v.[LGT], v.[PT], v.[FST], v.[NotarialFee], v.[Others], v.[PremiumsRemarks], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (8, N'GPB000000001', N'000000000001', 5, 27, 1, 3, 1, 1, 3, 1, 2, 3, NULL, NULL, NULL, 1, 11, 4, 27, 23, N'35265', N'885669', N'PPN-IMS3-001', N'EN-IMS3-001', '2026-06-07T00:00:00.0000000', '2025-06-07T00:00:00.0000000', '2025-06-07T00:00:00.0000000', N'Remarks', 10, 20, 30, 40, 130, 50, 60, 70, 80, 90, 100, 110, 120, N'Premium Remarks', 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (9, N'GPB000000002', N'000000000002', 5, 27, 1, 3, 1, 1, 3, 1, NULL, 3, 1, 3, 2, 1, 11, 7, 27, 23, NULL, NULL, N'PPN-IMS3-001', N'EN-IMS3-002', '2026-06-07T00:00:00.0000000', '2025-06-07T00:00:00.0000000', '2025-06-07T00:00:00.0000000', N'Remarks', 10, 20, 30, 40, 130, 50, 60, 70, 80, 90, 100, 110, 120, N'Premium Remarks', 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (10, N'GPB000000003', N'000000000003', 5, 27, 1, 3, 1, 1, 3, 1, 2, 3, NULL, NULL, NULL, 1, 11, 3, 27, 23, NULL, NULL, N'PPN-IMS3-001', N'EN-IMS3-003', '2026-06-07T00:00:00.0000000', '2025-06-07T00:00:00.0000000', '2025-06-07T00:00:00.0000000', N'Remarks', 10, 20, 30, 40, 130, 50, 60, 70, 80, 90, 100, 110, 120, N'Premium Remarks', 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [ReferenceNumber], [CocNumber], [PartnersId], [PlatformsId], [IssueStatus], [PolicyBookingStatusId], [CocStatusId], [PaymentStatusId], [ClaimsStatusId], [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId], [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId], [AccountTypeId], [BranchCode], [BranchName], [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks], [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes], [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Transaction].[GroupPolicy] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Transaction].[GroupPolicy] OFF;
GO

SET IDENTITY_INSERT [Transaction].[PolicyBeneficiary] ON;
INSERT INTO [Transaction].[PolicyBeneficiary] ([Id], [PolicyId], [PolicyTypeId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Relationship], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[PolicyId], v.[PolicyTypeId], v.[FirstName], v.[MiddleName], v.[LastName], v.[Suffix], v.[EmailAddress], v.[ContactNumber], v.[DateOfBirth], v.[Relationship], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (10, 1, 1, N'Maria', N'C', N'Santos', NULL, N'maria.santos@email.com', N'+639171234567', '1985-05-15T00:00:00.0000000', 7, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (11, 2, 1, N'John', NULL, N'Lim', N'Jr.', N'john.lim@email.com', N'+639189876543', '1990-11-22T00:00:00.0000000', 10, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (12, 1, 2, N'Sophia', N'R', N'Gonzales', NULL, N'sophia.g@email.com', N'+639201122334', '1978-01-30T00:00:00.0000000', 13, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (13, 2, 2, N'David', N'M', N'Reyes', N'III', N'david.r@email.com', N'+639165566778', '2005-08-01T00:00:00.0000000', 16, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (14, 8, 3, N'Anna', NULL, N'Cruz', NULL, N'anna.c@email.com', N'+639223344556', '1962-03-10T00:00:00.0000000', 18, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (15, 10, 3, N'Michael', N'J', N'Tan', NULL, N'michael.t@email.com', N'+639190099887', '1995-09-28T00:00:00.0000000', 20, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (16, 9, 3, N'Ella', N'P', N'Ramos', NULL, N'ella.ramos@email.com', N'+639151239876', '2000-07-25T00:00:00.0000000', 12, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [PolicyId], [PolicyTypeId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Relationship], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Transaction].[PolicyBeneficiary] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Transaction].[PolicyBeneficiary] OFF;
GO

SET IDENTITY_INSERT [Transaction].[PolicyBenefits] ON;
INSERT INTO [Transaction].[PolicyBenefits] ([Id], [PolicyId], [PolicyTypeId], [BenefitsId], [CoverageAmount], [PremiumAmount], [PremiumCommissionAmount], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[PolicyId], v.[PolicyTypeId], v.[BenefitsId], v.[CoverageAmount], v.[PremiumAmount], v.[PremiumCommissionAmount], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, 1, 1, 1, 20000.00, 7.93, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (2, 1, 1, 2, 20000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (3, 1, 1, 5, 5000.00, 4.11, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (4, 1, 1, 6, 1000.00, 3.13, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (5, 1, 1, 4, 5000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (6, 1, 1, 3, 5000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (7, 2, 1, 1, 20000.00, 7.93, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (8, 2, 1, 2, 20000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (9, 2, 1, 5, 5000.00, 4.11, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (10, 2, 1, 6, 1000.00, 3.13, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (11, 2, 1, 4, 5000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (12, 2, 1, 3, 5000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (13, 1, 2, 1, 20000.00, 7.93, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (14, 1, 2, 2, 20000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (15, 1, 2, 5, 5000.00, 4.11, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (16, 1, 2, 6, 1000.00, 3.13, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (17, 1, 2, 4, 5000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (18, 1, 2, 3, 5000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (19, 2, 2, 1, 20000.00, 7.93, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (20, 2, 2, 2, 20000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (21, 2, 2, 5, 5000.00, 4.11, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (22, 2, 2, 6, 1000.00, 3.13, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (23, 2, 2, 4, 5000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (24, 2, 2, 3, 5000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (25, 8, 3, 1, 20000.00, 7.93, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (26, 8, 3, 2, 20000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (27, 8, 3, 5, 5000.00, 4.11, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (28, 8, 3, 6, 1000.00, 3.13, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (29, 8, 3, 4, 5000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (30, 8, 3, 3, 5000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (31, 9, 3, 1, 20000.00, 7.93, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (32, 9, 3, 2, 20000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (33, 9, 3, 5, 5000.00, 4.11, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (34, 9, 3, 6, 1000.00, 3.13, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (35, 9, 3, 4, 5000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (36, 9, 3, 3, 5000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (37, 10, 3, 1, 20000.00, 7.93, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (38, 10, 3, 2, 20000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (39, 10, 3, 5, 5000.00, 4.11, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (40, 10, 3, 6, 1000.00, 3.13, 0.45, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (41, 10, 3, 4, 5000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (42, 10, 3, 3, 5000.00, 0.00, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [PolicyId], [PolicyTypeId], [BenefitsId], [CoverageAmount], [PremiumAmount], [PremiumCommissionAmount], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Transaction].[PolicyBenefits] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Transaction].[PolicyBenefits] OFF;
GO

SET IDENTITY_INSERT [Transaction].[PolicyDeductibles] ON;
INSERT INTO [Transaction].[PolicyDeductibles] ([Id], [PolicyId], [PolicyTypeId], [DeductiblesId], [Amount], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[PolicyId], v.[PolicyTypeId], v.[DeductiblesId], v.[Amount], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, 1, 1, 1, 254.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (2, 1, 1, 2, 344.90, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (3, 1, 1, 3, 5673.80, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (4, 1, 1, 4, 6653.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (5, 1, 1, 5, 234.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (6, 1, 1, 6, 2.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (7, 1, 1, 7, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (8, 1, 1, 8, 2321.70, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (9, 1, 1, 9, 223.70, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (10, 1, 1, 10, 32.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (11, 2, 1, 1, 254.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (12, 2, 1, 2, 344.90, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (13, 2, 1, 3, 5673.80, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (14, 2, 1, 4, 6653.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (15, 2, 1, 5, 234.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (16, 2, 1, 6, 2.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (17, 2, 1, 7, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (18, 2, 1, 8, 2321.70, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (19, 2, 1, 9, 223.70, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (20, 2, 1, 10, 32.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (21, 1, 2, 1, 254.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (22, 1, 2, 2, 344.90, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (23, 1, 2, 3, 5673.80, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (24, 1, 2, 4, 6653.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (25, 1, 2, 5, 234.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (26, 1, 2, 6, 2.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (27, 1, 2, 7, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (28, 1, 2, 8, 2321.70, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (29, 1, 2, 9, 223.70, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (30, 1, 2, 10, 32.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (31, 2, 2, 1, 254.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (32, 2, 2, 2, 344.90, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (33, 2, 2, 3, 5673.80, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (34, 2, 2, 4, 6653.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (35, 2, 2, 5, 234.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (36, 2, 2, 6, 2.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (37, 2, 2, 7, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (38, 2, 2, 8, 2321.70, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (39, 2, 2, 9, 223.70, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (40, 2, 2, 10, 32.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (41, 8, 3, 1, 254.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (42, 8, 3, 2, 344.90, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (43, 8, 3, 3, 5673.80, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (44, 8, 3, 4, 6653.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (45, 8, 3, 5, 234.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (46, 8, 3, 6, 2.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (47, 8, 3, 7, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (48, 8, 3, 8, 2321.70, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (49, 8, 3, 9, 223.70, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (50, 8, 3, 10, 32.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (51, 9, 3, 1, 254.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (52, 9, 3, 2, 344.90, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (53, 9, 3, 3, 5673.80, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (54, 9, 3, 4, 6653.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (55, 9, 3, 5, 234.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (56, 9, 3, 6, 2.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (57, 9, 3, 7, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (58, 9, 3, 8, 2321.70, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (59, 9, 3, 9, 223.70, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (60, 9, 3, 10, 32.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (61, 10, 3, 1, 254.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (62, 10, 3, 2, 344.90, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (63, 10, 3, 3, 5673.80, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (64, 10, 3, 4, 6653.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (65, 10, 3, 5, 234.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (66, 10, 3, 6, 2.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (67, 10, 3, 7, 0.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (68, 10, 3, 8, 2321.70, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (69, 10, 3, 9, 223.70, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (70, 10, 3, 10, 32.00, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [PolicyId], [PolicyTypeId], [DeductiblesId], [Amount], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Transaction].[PolicyDeductibles] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Transaction].[PolicyDeductibles] OFF;
GO

SET IDENTITY_INSERT [Transaction].[PolicyPayments] ON;
INSERT INTO [Transaction].[PolicyPayments] ([Id], [PolicyId], [PolicyTypeId], [Amount], [TransactionDateTime], [TransactionCheckNo], [TransactionOrigin], [NotificationDateTime], [PaymentMethod], [Notes], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[PolicyId], v.[PolicyTypeId], v.[Amount], v.[TransactionDateTime], v.[TransactionCheckNo], v.[TransactionOrigin], v.[NotificationDateTime], v.[PaymentMethod], v.[Notes], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, 1, 1, 645.17, '2025-06-07T08:04:12.1760000', N'CHK12345', N'Online', '2025-06-01T08:04:12.1760000', 27, NULL, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (2, 2, 1, 645.17, '2025-06-07T08:04:12.1760000', N'CHK12346', N'Branch', '2025-06-12T08:04:12.1760000', 28, N'Cash payment received', 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (3, 1, 2, 645.17, '2025-06-07T08:04:12.1760000', N'CHK12347', N'Agent', '2025-05-26T08:04:12.1760000', 29, NULL, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (4, 2, 2, 645.17, '2025-06-07T08:04:12.1760000', N'CHK12348', N'Online', '2025-06-20T08:04:12.1760000', 30, N'Via mobile app', 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (5, 8, 3, 645.17, '2025-06-07T08:04:12.1760000', N'CHK12349', N'Branch', '2025-06-11T08:04:12.1760000', 31, NULL, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (6, 9, 3, 645.17, '2025-06-07T08:04:12.1760000', N'CHK12350', N'CallCenter', '2025-06-01T08:04:12.1760000', 32, N'Phone payment', 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (7, 10, 3, 645.17, '2025-06-07T08:04:12.1760000', N'CHK12351', N'Online', '2025-06-20T08:04:12.1760000', 33, N'Autopay successful', 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [PolicyId], [PolicyTypeId], [Amount], [TransactionDateTime], [TransactionCheckNo], [TransactionOrigin], [NotificationDateTime], [PaymentMethod], [Notes], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Transaction].[PolicyPayments] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Transaction].[PolicyPayments] OFF;
GO

SET IDENTITY_INSERT [Transaction].[Attachments] ON;
INSERT INTO [Transaction].[Attachments] ([Id], [ReferenceId], [AttachmentTypeId], [ContentType], [FileName], [Attachment], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
SELECT v.[Id], v.[ReferenceId], v.[AttachmentTypeId], v.[ContentType], v.[FileName], v.[Attachment], v.[CreatedBy], v.[CreatedDateTime], v.[ModifiedBy], v.[ModifiedDateTime]
FROM (VALUES
    (1, 1, 1, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (4, 2, 1, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (5, 2, 2, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (6, 1, 2, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (7, 8, 3, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (8, 8, 4, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (9, 9, 4, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (10, 9, 3, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (11, 10, 3, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (12, 10, 4, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (14, 1, 5, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (15, 2, 5, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (16, 3, 5, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (17, 4, 5, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (18, 5, 5, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (19, 6, 5, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000'),
    (20, 7, 5, N'text/csv', N'SampleCSV.csv', 0xEFBBBF49642C4E616D652C4465736372697074696F6E2C4372656174656442792C437265617465644461746554696D652C4D6F64696669656442792C4D6F6469666965644461746554696D652C44656C6574656442792C44656C657465644461746554696D652C497344656C657465640D0A312C4163746976652C434F4320696E20666F7263653B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A322C436C61696D65642C52656665727320746F20737461747573206F662062656E6566697420696620616C726561647920636C61696D6564206F72206E6F743B2077696C6C20626520646566696E6564207065722062656E656669742C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A332C457870697265642C22434F43206973207465726D696E61746564206F6E206C61737420646179206F662065666665637469766974792064617465202865783A205365707420332C203230323020746F204A616E20332C203230323129222C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A342C43616E63656C6C65642C5375636365737366756C2073616C65732062757420636C69656E742072657175657374656420666F722063616E63656C6C6174696F6E2064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A352C566F69642C536F6C6420434F43E280997320627574206E6F742079657420656E636F64656420696E207468652073797374656D20616E642072657175657374656420746F2074616720617320566F69642064756520746F2076616C696420726561736F6E732C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A362C496E6163746976652C496E61637469766520434F432C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C323032352D30362D30322030303A30303A30302E303030303030302C4E554C4C2C4E554C4C2C300D0A, 500329, '2025-06-02T00:00:00.0000000', 500329, '2025-06-02T00:00:00.0000000')
) AS v ([Id], [ReferenceId], [AttachmentTypeId], [ContentType], [FileName], [Attachment], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
WHERE NOT EXISTS (SELECT 1 FROM [Transaction].[Attachments] AS t WHERE t.[Id] = v.[Id]);
SET IDENTITY_INSERT [Transaction].[Attachments] OFF;
GO

/* =====================================================================
   Demo data on top of the mock rows: more countries, Philippine cities and barangays,
   fictional people and companies (example.com contacts only), product set-up for every product,
   and about 500 policy bookings spread over the last three calendar years with their
   beneficiaries, benefits, deductibles, payments and attachments. Amounts are in PHP.
   Generated set-based and deterministically; each block only inserts what is missing.
   ===================================================================== */

DROP TABLE IF EXISTS #Numbers;
WITH [Digits] AS (SELECT [D] FROM (VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9)) AS v ([D]))
SELECT TOP (1000) CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS int) AS [N]
INTO #Numbers
FROM [Digits] AS a CROSS JOIN [Digits] AS b CROSS JOIN [Digits] AS c;
GO

/* ---------- Countries: Southeast Asia, East Asia and the Gulf (common OFW destinations) ---------- */

INSERT INTO [Static].[AddressRegionDivision] ([Id], [AddressRegionId], [Name], [Code])
SELECT v.[Id], v.[AddressRegionId], v.[Name], v.[Code]
FROM (VALUES (2, 1, N'East', N'EA'), (3, 1, N'West', N'WA')) AS v ([Id], [AddressRegionId], [Name], [Code])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[AddressRegionDivision] AS t WHERE t.[Id] = v.[Id]);

INSERT INTO [Static].[AddressCountry] ([Id], [AddressRegionDivisionId], [Name], [Code], [PhoneCode], [TopLevelDomain], [Currency], [CurrencyName], [Nationality])
SELECT v.[Id], v.[DivisionId], v.[Name], v.[Code], v.[PhoneCode], v.[Tld], v.[Currency], v.[CurrencyName], v.[Nationality]
FROM (VALUES
    (2, 1, N'Singapore', N'SG', N'+65', N'.sg', N'SGD', N'Singapore dollar', N'Singaporean'),
    (3, 1, N'Malaysia', N'MY', N'+60', N'.my', N'MYR', N'Malaysian ringgit', N'Malaysian'),
    (4, 1, N'Indonesia', N'ID', N'+62', N'.id', N'IDR', N'Indonesian rupiah', N'Indonesian'),
    (5, 1, N'Thailand', N'TH', N'+66', N'.th', N'THB', N'Thai baht', N'Thai'),
    (6, 1, N'Vietnam', N'VN', N'+84', N'.vn', N'VND', N'Vietnamese dong', N'Vietnamese'),
    (7, 1, N'Brunei', N'BN', N'+673', N'.bn', N'BND', N'Brunei dollar', N'Bruneian'),
    (8, 1, N'Cambodia', N'KH', N'+855', N'.kh', N'KHR', N'Cambodian riel', N'Cambodian'),
    (9, 1, N'Laos', N'LA', N'+856', N'.la', N'LAK', N'Lao kip', N'Lao'),
    (10, 1, N'Myanmar', N'MM', N'+95', N'.mm', N'MMK', N'Myanmar kyat', N'Burmese'),
    (11, 1, N'Timor-Leste', N'TL', N'+670', N'.tl', N'USD', N'United States dollar', N'Timorese'),
    (12, 2, N'Japan', N'JP', N'+81', N'.jp', N'JPY', N'Japanese yen', N'Japanese'),
    (13, 2, N'South Korea', N'KR', N'+82', N'.kr', N'KRW', N'South Korean won', N'South Korean'),
    (14, 2, N'China', N'CN', N'+86', N'.cn', N'CNY', N'Chinese yuan', N'Chinese'),
    (15, 3, N'Saudi Arabia', N'SA', N'+966', N'.sa', N'SAR', N'Saudi riyal', N'Saudi'),
    (16, 3, N'United Arab Emirates', N'AE', N'+971', N'.ae', N'AED', N'UAE dirham', N'Emirati'),
    (17, 3, N'Qatar', N'QA', N'+974', N'.qa', N'QAR', N'Qatari riyal', N'Qatari'),
    (18, 3, N'Kuwait', N'KW', N'+965', N'.kw', N'KWD', N'Kuwaiti dinar', N'Kuwaiti')
) AS v ([Id], [DivisionId], [Name], [Code], [PhoneCode], [Tld], [Currency], [CurrencyName], [Nationality])
WHERE NOT EXISTS (SELECT 1 FROM [Static].[AddressCountry] AS t WHERE t.[Id] = v.[Id]);
GO

/* ---------- Major Philippine cities and municipalities, placed under the mock provinces by name ---------- */

INSERT INTO [Static].[AddressCity] ([Id], [AddressStateId], [Name])
SELECT v.[Id], s.[Id], v.[Name]
FROM (VALUES
    (2001, N'Quezon City', N'Metro Manila'), (2002, N'Makati City', N'Metro Manila'), (2003, N'Taguig City', N'Metro Manila'),
    (2004, N'Pasig City', N'Metro Manila'), (2005, N'Mandaluyong City', N'Metro Manila'), (2006, N'Marikina City', N'Metro Manila'),
    (2007, N'Parañaque City', N'Metro Manila'), (2008, N'Las Piñas City', N'Metro Manila'), (2009, N'Muntinlupa City', N'Metro Manila'),
    (2010, N'Valenzuela City', N'Metro Manila'), (2011, N'Malabon City', N'Metro Manila'), (2012, N'Navotas City', N'Metro Manila'),
    (2013, N'San Juan City', N'Metro Manila'), (2014, N'Pateros', N'Metro Manila'),
    (2015, N'Laoag City (Capital)', N'Ilocos Norte'), (2016, N'Batac City', N'Ilocos Norte'), (2017, N'Candon City', N'Ilocos Sur'),
    (2018, N'San Fernando City (Capital)', N'La Union'), (2019, N'Dagupan City', N'Pangasinan'), (2020, N'Urdaneta City', N'Pangasinan'),
    (2021, N'Lingayen (Capital)', N'Pangasinan'), (2022, N'San Carlos City', N'Pangasinan'),
    (2023, N'Ilagan City (Capital)', N'Isabela'), (2024, N'Cauayan City', N'Isabela'), (2025, N'Bayombong (Capital)', N'Nueva Vizcaya'),
    (2026, N'Balanga City (Capital)', N'Bataan'), (2027, N'Malolos City (Capital)', N'Bulacan'), (2028, N'Meycauayan City', N'Bulacan'),
    (2029, N'San Jose del Monte City', N'Bulacan'), (2030, N'Cabanatuan City', N'Nueva Ecija'), (2031, N'Palayan City (Capital)', N'Nueva Ecija'),
    (2032, N'San Fernando City (Capital)', N'Pampanga'), (2033, N'Angeles City', N'Pampanga'), (2034, N'Mabalacat City', N'Pampanga'),
    (2035, N'Tarlac City (Capital)', N'Tarlac'), (2036, N'Olongapo City', N'Zambales'), (2037, N'Iba (Capital)', N'Zambales'),
    (2038, N'Baler (Capital)', N'Aurora'),
    (2039, N'Batangas City (Capital)', N'Batangas'), (2040, N'Lipa City', N'Batangas'), (2041, N'Tanauan City', N'Batangas'),
    (2042, N'Bacoor City', N'Cavite'), (2043, N'Dasmariñas City', N'Cavite'), (2044, N'Imus City', N'Cavite'),
    (2045, N'Tagaytay City', N'Cavite'), (2046, N'General Trias City', N'Cavite'),
    (2047, N'Calamba City', N'Laguna'), (2048, N'Santa Rosa City', N'Laguna'), (2049, N'San Pablo City', N'Laguna'),
    (2050, N'Biñan City', N'Laguna'), (2051, N'Santa Cruz (Capital)', N'Laguna'),
    (2052, N'Lucena City', N'Quezon'), (2053, N'Tayabas City', N'Quezon'),
    (2054, N'Antipolo City (Capital)', N'Rizal'), (2055, N'Cainta', N'Rizal'), (2056, N'Taytay', N'Rizal'),
    (2057, N'Puerto Princesa City', N'Palawan'), (2058, N'Calapan City (Capital)', N'Oriental Mindoro'),
    (2059, N'Mamburao (Capital)', N'Occidental Mindoro'), (2060, N'Romblon (Capital)', N'Romblon'),
    (2061, N'Legazpi City (Capital)', N'Albay'), (2062, N'Tabaco City', N'Albay'), (2063, N'Naga City', N'Camarines Sur'),
    (2064, N'Pili (Capital)', N'Camarines Sur'), (2065, N'Sorsogon City (Capital)', N'Sorsogon'), (2066, N'Daet (Capital)', N'Camarines Norte'),
    (2067, N'Masbate City (Capital)', N'Masbate'), (2068, N'Virac (Capital)', N'Catanduanes'),
    (2069, N'Bacolod City (Capital)', N'Negros Occidental'), (2070, N'Silay City', N'Negros Occidental'), (2071, N'Roxas City (Capital)', N'Capiz'),
    (2072, N'San Jose de Buenavista (Capital)', N'Antique'), (2073, N'Jordan (Capital)', N'Guimaras'), (2074, N'Malay', N'Aklan'),
    (2075, N'Cebu City (Capital)', N'Cebu'), (2076, N'Mandaue City', N'Cebu'), (2077, N'Lapu-Lapu City', N'Cebu'), (2078, N'Talisay City', N'Cebu'),
    (2079, N'Tagbilaran City (Capital)', N'Bohol'), (2080, N'Dumaguete City (Capital)', N'Negros Oriental'), (2081, N'Siquijor (Capital)', N'Siquijor'),
    (2082, N'Tacloban City', N'Leyte'), (2083, N'Catbalogan City (Capital)', N'Samar'), (2084, N'Calbayog City', N'Samar'),
    (2085, N'Maasin City (Capital)', N'Southern Leyte'), (2086, N'Borongan City (Capital)', N'Eastern Samar'), (2087, N'Catarman (Capital)', N'Northern Samar'),
    (2088, N'Naval (Capital)', N'Biliran'),
    (2089, N'Zamboanga City', N'Zamboanga del Sur'), (2090, N'Dipolog City (Capital)', N'Zamboanga del Norte'), (2091, N'Dapitan City', N'Zamboanga del Norte'),
    (2092, N'Ipil (Capital)', N'Zamboanga Sibugay'),
    (2093, N'Cagayan de Oro City (Capital)', N'Misamis Oriental'), (2094, N'Gingoog City', N'Misamis Oriental'), (2095, N'Malaybalay City (Capital)', N'Bukidnon'),
    (2096, N'Valencia City', N'Bukidnon'), (2097, N'Iligan City', N'Lanao del Norte'), (2098, N'Ozamiz City', N'Misamis Occidental'),
    (2099, N'Oroquieta City (Capital)', N'Misamis Occidental'), (2100, N'Mambajao (Capital)', N'Camiguin'),
    (2101, N'Davao City', N'Davao del Sur'), (2102, N'Digos City (Capital)', N'Davao del Sur'), (2103, N'Tagum City (Capital)', N'Davao del Norte'),
    (2104, N'Panabo City', N'Davao del Norte'), (2105, N'Island Garden City of Samal', N'Davao del Norte'), (2106, N'Mati City (Capital)', N'Davao Oriental'),
    (2107, N'Nabunturan (Capital)', N'Davao de Oro'),
    (2108, N'General Santos City', N'South Cotabato'), (2109, N'Koronadal City (Capital)', N'South Cotabato'), (2110, N'Kidapawan City (Capital)', N'Cotabato'),
    (2111, N'Tacurong City', N'Sultan Kudarat'), (2112, N'Alabel (Capital)', N'Sarangani'),
    (2113, N'La Trinidad (Capital)', N'Benguet'), (2114, N'Bangued (Capital)', N'Abra'), (2115, N'Lagawe (Capital)', N'Ifugao'),
    (2116, N'Tabuk City (Capital)', N'Kalinga'), (2117, N'Bontoc (Capital)', N'Mountain Province'),
    (2118, N'Cotabato City', N'Maguindanao'), (2119, N'Marawi City (Capital)', N'Lanao del Sur'), (2120, N'Isabela City', N'Basilan'),
    (2121, N'Jolo (Capital)', N'Sulu'), (2122, N'Bongao (Capital)', N'Tawi-Tawi'),
    (2123, N'Butuan City', N'Agusan del Norte'), (2124, N'Surigao City (Capital)', N'Surigao del Norte'), (2125, N'Tandag City (Capital)', N'Surigao del Sur'),
    (2126, N'Bayugan City', N'Agusan del Sur'), (2127, N'San Jose (Capital)', N'Dinagat Islands')
) AS v ([Id], [Name], [StateName])
INNER JOIN [Static].[AddressState] AS s ON s.[Name] = v.[StateName]
WHERE NOT EXISTS (SELECT 1 FROM [Static].[AddressCity] AS t WHERE t.[Id] = v.[Id]);
GO

/* ---------- Barangays: named ones for the biggest cities, the most common barangay names for every other city ---------- */

INSERT INTO [Static].[AddressTown] ([Id], [AddressCityId], [Name], [Code])
SELECT 1000000 + v.[CityId] * 100 + v.[K], v.[CityId], v.[Name], N'0'
FROM (VALUES
    (2001, 1, N'Bagong Pag-asa'), (2001, 2, N'Batasan Hills'), (2001, 3, N'Commonwealth'), (2001, 4, N'Holy Spirit'), (2001, 5, N'Kamuning'), (2001, 6, N'Teachers Village East'),
    (2002, 1, N'Bel-Air'), (2002, 2, N'Poblacion'), (2002, 3, N'San Lorenzo'), (2002, 4, N'Urdaneta'), (2002, 5, N'Pio del Pilar'), (2002, 6, N'Guadalupe Nuevo'),
    (2003, 1, N'Fort Bonifacio'), (2003, 2, N'Western Bicutan'), (2003, 3, N'Ususan'), (2003, 4, N'Lower Bicutan'), (2003, 5, N'Pinagsama'),
    (2004, 1, N'Kapitolyo'), (2004, 2, N'Ugong'), (2004, 3, N'San Antonio'), (2004, 4, N'Rosario'), (2004, 5, N'Manggahan'),
    (2005, 1, N'Wack-Wack Greenhills'), (2005, 2, N'Highway Hills'), (2005, 3, N'Plainview'), (2005, 4, N'Addition Hills'), (2005, 5, N'Barangka Drive'),
    (2075, 1, N'Lahug'), (2075, 2, N'Mabolo'), (2075, 3, N'Guadalupe'), (2075, 4, N'Capitol Site'), (2075, 5, N'Banilad'), (2075, 6, N'Talamban'),
    (2101, 1, N'Buhangin'), (2101, 2, N'Talomo'), (2101, 3, N'Matina Crossing'), (2101, 4, N'Toril'), (2101, 5, N'Agdao'), (2101, 6, N'Bajada')
) AS v ([CityId], [K], [Name])
WHERE EXISTS (SELECT 1 FROM [Static].[AddressCity] AS c WHERE c.[Id] = v.[CityId])
  AND NOT EXISTS (SELECT 1 FROM [Static].[AddressTown] AS t WHERE t.[Id] = 1000000 + v.[CityId] * 100 + v.[K]);

WITH [CommonNames] AS
(
    SELECT [K], [Name]
    FROM (VALUES (0, N'San Isidro'), (1, N'San Roque'), (2, N'Santo Niño'), (3, N'San Jose'), (4, N'San Antonio'), (5, N'Santa Cruz'),
                 (6, N'San Vicente'), (7, N'Bagong Silang'), (8, N'Mabini'), (9, N'Rizal'), (10, N'Bagumbayan')) AS v ([K], [Name])
)
INSERT INTO [Static].[AddressTown] ([Id], [AddressCityId], [Name], [Code])
SELECT 1000000 + c.[Id] * 100 + 10 + s.[Slot], c.[Id], x.[Name], N'0'
FROM [Static].[AddressCity] AS c
CROSS JOIN (VALUES (1), (2), (3), (4), (5)) AS s ([Slot])
CROSS APPLY
(
    SELECT CASE WHEN s.[Slot] = 1 THEN N'Poblacion' ELSE (SELECT n.[Name] FROM [CommonNames] AS n WHERE n.[K] = (c.[Id] + s.[Slot] * 5) % 11) END AS [Name]
) AS x
WHERE NOT EXISTS (SELECT 1 FROM [Static].[AddressTown] AS t WHERE t.[AddressCityId] = c.[Id] AND t.[Id] >= 1000000)
  AND NOT EXISTS (SELECT 1 FROM [Static].[AddressTown] AS t WHERE t.[AddressCityId] = c.[Id] AND t.[Name] = x.[Name]);
GO

/* ---------- Name lists for generated people ---------- */

DROP TABLE IF EXISTS #FirstNames;
DROP TABLE IF EXISTS #LastNames;
DROP TABLE IF EXISTS #Streets;
DROP TABLE IF EXISTS #Towns;

SELECT v.[K], v.[Name], v.[IsMale]
INTO #FirstNames
FROM (VALUES
    (0, N'Juan', 1), (1, N'Jose', 1), (2, N'Mark Anthony', 1), (3, N'John Paul', 1), (4, N'Christian', 1), (5, N'Rommel', 1), (6, N'Rodel', 1), (7, N'Jerome', 1),
    (8, N'Arnel', 1), (9, N'Rogelio', 1), (10, N'Eduardo', 1), (11, N'Ramon', 1), (12, N'Danilo', 1), (13, N'Ferdinand', 1), (14, N'Joel', 1), (15, N'Noel', 1),
    (16, N'Marlon', 1), (17, N'Reynaldo', 1), (18, N'Paolo', 1), (19, N'Miguel', 1), (20, N'Carlo', 1), (21, N'Angelo', 1), (22, N'Gabriel', 1), (23, N'Rafael', 1),
    (24, N'Joshua', 1), (25, N'Kenneth', 1), (26, N'Bryan', 1), (27, N'Ronaldo', 1), (28, N'Ernesto', 1), (29, N'Romeo', 1), (30, N'Alfredo', 1), (31, N'Benjamin', 1),
    (32, N'Emmanuel', 1), (33, N'Francis', 1), (34, N'Gerardo', 1), (35, N'Nestor', 1), (36, N'Renato', 1), (37, N'Vicente', 1), (38, N'Wilfredo', 1), (39, N'Arturo', 1),
    (0, N'Maria Cristina', 0), (1, N'Ana Marie', 0), (2, N'Rosario', 0), (3, N'Teresita', 0), (4, N'Lorna', 0), (5, N'Marites', 0), (6, N'Jocelyn', 0), (7, N'Maricel', 0),
    (8, N'Rowena', 0), (9, N'Analyn', 0), (10, N'Kristine', 0), (11, N'Jennifer', 0), (12, N'Michelle', 0), (13, N'Mary Grace', 0), (14, N'Camille', 0), (15, N'Patricia', 0),
    (16, N'Angelica', 0), (17, N'Nicole', 0), (18, N'Kimberly', 0), (19, N'Precious', 0), (20, N'Princess', 0), (21, N'Divina', 0), (22, N'Erlinda', 0), (23, N'Gloria', 0),
    (24, N'Leonora', 0), (25, N'Corazon', 0), (26, N'Imelda', 0), (27, N'Lourdes', 0), (28, N'Remedios', 0), (29, N'Sheila', 0), (30, N'Rachelle', 0), (31, N'Joy', 0),
    (32, N'Hazel', 0), (33, N'Liza', 0), (34, N'Cristina', 0), (35, N'Elena', 0), (36, N'Victoria', 0), (37, N'Bea', 0), (38, N'Andrea', 0), (39, N'Danica', 0)
) AS v ([K], [Name], [IsMale]);

SELECT v.[K], v.[Name]
INTO #LastNames
FROM (VALUES
    (0, N'Dela Cruz'), (1, N'Garcia'), (2, N'Reyes'), (3, N'Ramos'), (4, N'Mendoza'), (5, N'Santos'), (6, N'Flores'), (7, N'Gonzales'), (8, N'Bautista'), (9, N'Villanueva'),
    (10, N'Fernandez'), (11, N'Cruz'), (12, N'De Guzman'), (13, N'Lopez'), (14, N'Perez'), (15, N'Castillo'), (16, N'Francisco'), (17, N'Rivera'), (18, N'Aquino'), (19, N'Castro'),
    (20, N'Sanchez'), (21, N'Torres'), (22, N'De Leon'), (23, N'Domingo'), (24, N'Martinez'), (25, N'Rodriguez'), (26, N'Santiago'), (27, N'Soriano'), (28, N'Delos Santos'), (29, N'Diaz'),
    (30, N'Hernandez'), (31, N'Tolentino'), (32, N'Valdez'), (33, N'Ramirez'), (34, N'Morales'), (35, N'Mercado'), (36, N'Tan'), (37, N'Aguilar'), (38, N'Navarro'), (39, N'Manalo'),
    (40, N'Gomez'), (41, N'Dizon'), (42, N'Del Rosario'), (43, N'Javier'), (44, N'Corpuz'), (45, N'Gutierrez'), (46, N'Salazar'), (47, N'Sarmiento'), (48, N'Pascual'), (49, N'Lim'),
    (50, N'Panganiban'), (51, N'Macaraeg'), (52, N'Magbanua'), (53, N'Dimaculangan'), (54, N'Pangilinan'), (55, N'Bernardo'), (56, N'Agustin'), (57, N'Ocampo'), (58, N'Mangubat'), (59, N'Cabrera')
) AS v ([K], [Name]);

SELECT v.[K], v.[Name]
INTO #Streets
FROM (VALUES
    (0, N'Rizal St.'), (1, N'Mabini St.'), (2, N'Bonifacio Ave.'), (3, N'Luna St.'), (4, N'Del Pilar St.'), (5, N'Burgos St.'), (6, N'Quezon Ave.'), (7, N'Aguinaldo Hwy.'),
    (8, N'Magsaysay Blvd.'), (9, N'Osmeña St.'), (10, N'Sampaguita St.'), (11, N'Ilang-Ilang St.'), (12, N'Narra St.'), (13, N'Acacia Ave.'), (14, N'Molave St.'), (15, N'Kamagong St.')
) AS v ([K], [Name]);

SELECT CAST(ROW_NUMBER() OVER (ORDER BY t.[Id]) - 1 AS int) AS [K], t.[Id]
INTO #Towns
FROM [Static].[AddressTown] AS t
WHERE t.[IsDeleted] = 0;
GO

/* ---------- People: agents, sub-agents, approvers, promo managers, promo officers, sales managers, clients ---------- */

DROP TABLE IF EXISTS #People;

DECLARE @Today date = CAST(SYSUTCDATETIME() AS date);
DECLARE @TownCount int = (SELECT COUNT(*) FROM #Towns);

WITH [Kinds] AS
(
    SELECT [Kind], [Prefix], [Total], [Salt]
    FROM (VALUES (N'AGT', N'AGT', 40, 1), (N'SAG', N'SAG', 60, 2), (N'APR', N'APR', 15, 3), (N'PMG', N'PMG', 30, 4),
                 (N'POF', N'POF', 40, 5), (N'SMG', N'SMG', 30, 6), (N'CLI', N'INSC2', 300, 7)) AS v ([Kind], [Prefix], [Total], [Salt])
)
SELECT
    k.[Kind],
    n.[N],
    CASE WHEN k.[Kind] = N'CLI' THEN CONCAT(k.[Prefix], RIGHT(CONCAT(N'00000', n.[N]), 5)) ELSE CONCAT(k.[Prefix], 2000 + n.[N]) END AS [Code],
    g.[IsMale],
    f.[Name] AS [FirstName],
    CASE WHEN (n.[N] + k.[Salt]) % 5 = 0 THEN NULL ELSE m.[Name] END AS [MiddleName],
    l.[Name] AS [LastName],
    CASE WHEN g.[IsMale] = 1 AND (n.[N] * 3 + k.[Salt]) % 19 = 0 THEN N'Jr.' WHEN g.[IsMale] = 1 AND (n.[N] * 3 + k.[Salt]) % 37 = 1 THEN N'III' END AS [Suffix],
    LOWER(CONCAT(REPLACE(f.[Name], N' ', N''), N'.', REPLACE(l.[Name], N' ', N''), n.[N], k.[Salt], N'@example.com')) AS [EmailAddress],
    CONCAT(N'+639', RIGHT(CONCAT(N'000000000', (CAST(n.[N] AS bigint) * 7919 + k.[Salt] * 104729 + 150000000) % 1000000000), 9)) AS [ContactNumber],
    CASE WHEN k.[Kind] = N'CLI'
         THEN DATEADD(DAY, -((n.[N] * 397 + k.[Salt] * 31) % 17000), CAST('2004-06-30' AS date))
         ELSE DATEADD(DAY, -((n.[N] * 397 + k.[Salt] * 31) % 10000), CAST('2001-06-30' AS date)) END AS [DateOfBirth],
    CONCAT((n.[N] * 7 + k.[Salt]) % 250 + 1, N' ', st.[Name]) AS [Address1],
    CASE (n.[N] + k.[Salt]) % 4 WHEN 0 THEN CONCAT(N'Blk ', n.[N] % 20 + 1, N' Lot ', n.[N] % 30 + 1) WHEN 1 THEN CONCAT(N'Unit ', n.[N] % 12 + 1, N'B') END AS [Address2],
    tw.[Id] AS [AddressTownId],
    CAST(CASE WHEN (n.[N] * 5 + k.[Salt]) % 11 = 0 THEN 0 ELSE 1 END AS bit) AS [IsActive],
    (n.[N] + k.[Salt]) % 6 + 1 AS [ValidIdPresented],
    CAST(DATEADD(MINUTE, (n.[N] * 97) % 540,
         CAST(DATEADD(DAY, -CASE WHEN k.[Kind] = N'CLI' THEN (n.[N] * 37 + k.[Salt] * 17) % 1060 + 1 ELSE 400 + (n.[N] * 37 + k.[Salt] * 17) % 800 END, @Today) AS datetime2(7))) AS datetime2(7)) AS [CreatedDateTime]
INTO #People
FROM [Kinds] AS k
INNER JOIN #Numbers AS n ON n.[N] <= k.[Total]
CROSS APPLY (SELECT CAST((n.[N] * 7 + k.[Salt]) % 2 AS bit) AS [IsMale]) AS g
INNER JOIN #FirstNames AS f ON f.[IsMale] = g.[IsMale] AND f.[K] = (n.[N] * 11 + k.[Salt] * 7) % 40
INNER JOIN #LastNames AS l ON l.[K] = (n.[N] * 17 + k.[Salt] * 13) % 60
INNER JOIN #LastNames AS m ON m.[K] = (n.[N] * 23 + k.[Salt] * 5 + 1) % 60
INNER JOIN #Streets AS st ON st.[K] = (n.[N] * 3 + k.[Salt]) % 16
INNER JOIN #Towns AS tw ON tw.[K] = (n.[N] * 37 + k.[Salt] * 11) % @TownCount;

INSERT INTO [Reference].[Agents]
    ([DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedDateTime], [ModifiedDateTime])
SELECT p.[Code], p.[FirstName], p.[MiddleName], p.[LastName], p.[Suffix], p.[EmailAddress], p.[ContactNumber], p.[DateOfBirth], p.[Address1], p.[Address2], p.[AddressTownId], p.[IsActive], p.[CreatedDateTime], p.[CreatedDateTime]
FROM #People AS p
WHERE p.[Kind] = N'AGT' AND NOT EXISTS (SELECT 1 FROM [Reference].[Agents] AS t WHERE t.[DJDPatricioOrAgentId] = p.[Code])
ORDER BY p.[N];

INSERT INTO [Reference].[SubAgents]
    ([DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedDateTime], [ModifiedDateTime])
SELECT p.[Code], p.[FirstName], p.[MiddleName], p.[LastName], p.[Suffix], p.[EmailAddress], p.[ContactNumber], p.[DateOfBirth], p.[Address1], p.[Address2], p.[AddressTownId], p.[IsActive], p.[CreatedDateTime], p.[CreatedDateTime]
FROM #People AS p
WHERE p.[Kind] = N'SAG' AND NOT EXISTS (SELECT 1 FROM [Reference].[SubAgents] AS t WHERE t.[DJDPatricioOrAgentId] = p.[Code])
ORDER BY p.[N];

INSERT INTO [Reference].[Approvers]
    ([DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedDateTime], [ModifiedDateTime])
SELECT p.[Code], p.[FirstName], p.[MiddleName], p.[LastName], p.[Suffix], p.[EmailAddress], p.[ContactNumber], p.[DateOfBirth], p.[Address1], p.[Address2], p.[AddressTownId], p.[IsActive], p.[CreatedDateTime], p.[CreatedDateTime]
FROM #People AS p
WHERE p.[Kind] = N'APR' AND NOT EXISTS (SELECT 1 FROM [Reference].[Approvers] AS t WHERE t.[DJDPatricioOrAgentId] = p.[Code])
ORDER BY p.[N];

INSERT INTO [Reference].[PromoManagers]
    ([AgentsId], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedDateTime], [ModifiedDateTime])
SELECT a.[Id], p.[Code], p.[FirstName], p.[MiddleName], p.[LastName], p.[Suffix], p.[EmailAddress], p.[ContactNumber], p.[DateOfBirth], p.[Address1], p.[Address2], p.[AddressTownId], p.[IsActive], p.[CreatedDateTime], p.[CreatedDateTime]
FROM #People AS p
INNER JOIN [Reference].[Agents] AS a ON a.[DJDPatricioOrAgentId] = CONCAT(N'AGT', 2000 + (p.[N] - 1) % 40 + 1)
WHERE p.[Kind] = N'PMG' AND NOT EXISTS (SELECT 1 FROM [Reference].[PromoManagers] AS t WHERE t.[DJDPatricioOrAgentId] = p.[Code])
ORDER BY p.[N];

INSERT INTO [Reference].[PromoOfficers]
    ([AgentsId], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedDateTime], [ModifiedDateTime])
SELECT a.[Id], p.[Code], p.[FirstName], p.[MiddleName], p.[LastName], p.[Suffix], p.[EmailAddress], p.[ContactNumber], p.[DateOfBirth], p.[Address1], p.[Address2], p.[AddressTownId], p.[IsActive], p.[CreatedDateTime], p.[CreatedDateTime]
FROM #People AS p
INNER JOIN [Reference].[Agents] AS a ON a.[DJDPatricioOrAgentId] = CONCAT(N'AGT', 2000 + (p.[N] - 1) % 40 + 1)
WHERE p.[Kind] = N'POF' AND NOT EXISTS (SELECT 1 FROM [Reference].[PromoOfficers] AS t WHERE t.[DJDPatricioOrAgentId] = p.[Code])
ORDER BY p.[N];

INSERT INTO [Reference].[SalesManagers]
    ([AgentsId], [DJDPatricioOrAgentId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedDateTime], [ModifiedDateTime])
SELECT a.[Id], p.[Code], p.[FirstName], p.[MiddleName], p.[LastName], p.[Suffix], p.[EmailAddress], p.[ContactNumber], p.[DateOfBirth], p.[Address1], p.[Address2], p.[AddressTownId], p.[IsActive], p.[CreatedDateTime], p.[CreatedDateTime]
FROM #People AS p
INNER JOIN [Reference].[Agents] AS a ON a.[DJDPatricioOrAgentId] = CONCAT(N'AGT', 2000 + (p.[N] - 1) % 40 + 1)
WHERE p.[Kind] = N'SMG' AND NOT EXISTS (SELECT 1 FROM [Reference].[SalesManagers] AS t WHERE t.[DJDPatricioOrAgentId] = p.[Code])
ORDER BY p.[N];

INSERT INTO [Reference].[Clients]
    ([InsuranceCustomerNo], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [IsMale],
     [ValidIdPresented], [ValidIdPresentedNumber], [ValidIdExpiration], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedDateTime], [ModifiedDateTime])
SELECT
    p.[Code], p.[FirstName], p.[MiddleName], p.[LastName], p.[Suffix], p.[EmailAddress], p.[ContactNumber], p.[DateOfBirth], p.[IsMale],
    sl.[Id],
    CASE p.[ValidIdPresented]
        WHEN 1 THEN CONCAT(N'N01-', RIGHT(CONCAT(N'00', p.[N] % 100), 2), N'-', RIGHT(CONCAT(N'000000', p.[N] * 4241 % 1000000), 6))
        WHEN 2 THEN CONCAT(N'P', RIGHT(CONCAT(N'0000000', p.[N] * 7393 % 10000000), 7), N'A')
        WHEN 3 THEN CONCAT(N'34-', RIGHT(CONCAT(N'0000000', p.[N] * 5167 % 10000000), 7), N'-', p.[N] % 10)
        WHEN 4 THEN CONCAT(N'CRN-0111-', RIGHT(CONCAT(N'0000000', p.[N] * 6113 % 10000000), 7), N'-', p.[N] % 10)
        WHEN 5 THEN CONCAT(N'VIN', RIGHT(CONCAT(N'0000000000', CAST(p.[N] AS bigint) * 81239 % 10000000000), 10))
        ELSE CONCAT(N'12-', RIGHT(CONCAT(N'000000000', CAST(p.[N] AS bigint) * 37591 % 1000000000), 9), N'-', p.[N] % 10)
    END,
    DATEADD(DAY, (p.[N] * 91) % 2200, CAST('2026-06-01' AS date)),
    p.[Address1], p.[Address2], p.[AddressTownId], p.[IsActive], p.[CreatedDateTime], p.[CreatedDateTime]
FROM #People AS p
INNER JOIN [Reference].[SelectionList] AS sl ON sl.[SelectionTypeId] = 1 AND sl.[Id] = p.[ValidIdPresented]
WHERE p.[Kind] = N'CLI' AND NOT EXISTS (SELECT 1 FROM [Reference].[Clients] AS t WHERE t.[InsuranceCustomerNo] = p.[Code])
ORDER BY p.[N];
GO

/* ---------- Partners (banks, remittance, pawnshops, cooperatives) and providers (insurers, HMOs); all names fictional ---------- */

DECLARE @Today date = CAST(SYSUTCDATETIME() AS date);

INSERT INTO [Reference].[Partners]
    ([Name], [Description], [Code], [ContactPerson], [EmailAddress], [ContactNumber], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedDateTime], [ModifiedDateTime])
SELECT v.[Name], v.[Description], v.[Code], v.[ContactPerson], CONCAT(N'partners.', LOWER(v.[Code]), N'@example.com'),
       CONCAT(N'+6391', RIGHT(CONCAT(N'00000000', v.[Seed] * 7717 % 100000000), 8)), v.[Address1], NULL, t.[Id],
       CAST(CASE WHEN v.[Seed] % 9 = 0 THEN 0 ELSE 1 END AS bit),
       DATEADD(DAY, -v.[DaysAgo], CAST(@Today AS datetime2(7))), DATEADD(DAY, -v.[DaysAgo], CAST(@Today AS datetime2(7)))
FROM (VALUES
    (21, N'Bayanihan Rural Bank of Batangas', N'Rural bank partner for loan-protect and personal accident bundles', N'BRB21', N'Corazon M. Dimaculangan', N'88 P. Burgos St.', 2039, 1010),
    (22, N'Kalinga Savings Bank', N'Thrift bank partner; credit life for salary loans', N'KSB22', N'Ramon T. Agustin', N'201 Rizal Ave.', 2001, 980),
    (23, N'Mabuhay Remittance Center', N'Remittance partner selling micro personal accident at the counter', N'MRC23', N'Liza P. Manalo', N'14 Quezon Ave.', 2004, 940),
    (24, N'Pinoy Padala Express', N'Remittance and bills payment network', N'PPE24', N'Joel S. Pascual', N'7 Mabini St.', 2075, 900),
    (25, N'Ginintuang Pawnshop Inc.', N'Pawnshop chain; pawn-protect and fire cash assistance', N'GPI25', N'Teresita R. Lim', N'55 Osmeña Blvd.', 2075, 870),
    (26, N'Bagong Araw Pawnshop', N'Pawnshop partner in Mindanao', N'BAP26', N'Danilo C. Magbanua', N'12 C.M. Recto Ave.', 2101, 830),
    (27, N'Lingap Multi-Purpose Cooperative', N'Cooperative partner; member group personal accident', N'LMC27', N'Rosario B. Ocampo', N'3 Bonifacio St.', 2063, 800),
    (28, N'Masagana Credit Cooperative', N'Credit cooperative for farmers and fisherfolk', N'MCC28', N'Ernesto V. Bernardo', N'19 Luna St.', 2030, 770),
    (29, N'Tagumpay Microfinance Inc.', N'Microfinance NGO; credit life and hospital income', N'TMI29', N'Maricel D. Sarmiento', N'40 Del Pilar St.', 2069, 740),
    (30, N'Visayas Countryside Bank', N'Countryside bank partner', N'VCB30', N'Rafael G. Tolentino', N'101 Lacson St.', 2069, 700),
    (31, N'Mindanao Development Lending', N'Lending company partner', N'MDL31', N'Hazel A. Cabrera', N'26 Corrales Ave.', 2093, 660),
    (32, N'Luzon Thrift Bank', N'Thrift bank partner', N'LTB32', N'Benjamin O. Javier', N'9 MacArthur Hwy.', 2033, 620),
    (33, N'Kabalikat Remit Services', N'Remittance partner for OFW families', N'KRS33', N'Jocelyn F. Corpuz', N'5 Aguinaldo Hwy.', 2042, 580),
    (34, N'Sulit Padala Center', N'Remittance and e-load outlet network', N'SPC34', N'Arnel P. Dizon', N'77 National Rd.', 2047, 540),
    (35, N'Perlas Pawnshop and Jewelry', N'Pawnshop partner', N'PPJ35', N'Gloria S. Del Rosario', N'31 Real St.', 2082, 500),
    (36, N'Bantay Kabuhayan Foundation', N'Livelihood foundation; group personal accident for members', N'BKF36', N'Nestor L. Macaraeg', N'2 Session Rd.', 1395, 460),
    (37, N'Agapay Lending Corp.', N'Consumer lending partner', N'ALC37', N'Analyn K. Panganiban', N'18 Shaw Blvd.', 2005, 420),
    (38, N'Silangan Savings and Loan', N'Savings and loan association', N'SSL38', N'Vicente E. Salazar', N'60 Ortigas Ave.', 2004, 380),
    (39, N'Kapatiran Cooperative Bank', N'Cooperative bank partner', N'KCB39', N'Imelda R. Gutierrez', N'11 J.P. Laurel Ave.', 2101, 340),
    (40, N'Haraya Digital Payments', N'E-wallet partner selling digital micro insurance', N'HDP40', N'Paolo M. Navarro', N'32nd St. corner 5th Ave.', 2003, 300),
    (41, N'Tahanan Homebuyers Credit', N'Housing loan partner; mortgage redemption and fire', N'THC41', N'Rowena J. Aguilar', N'45 Molino Blvd.', 2042, 260),
    (42, N'Biyaheng Ligtas Travel and Tours', N'Travel agency partner for travel insurance', N'BLT42', N'Angelo T. Mercado', N'8 Paseo de Roxas', 2002, 220),
    (43, N'Kaagapay OFW Services', N'OFW services agency', N'KOS43', N'Kristine A. Valdez', N'120 Taft Ave.', 1350, 180),
    (44, N'Matatag Motor Finance', N'Motorcycle financing partner; motor insurance', N'MMF44', N'Rodel C. Mangubat', N'3 Diversion Rd.', 2063, 150),
    (45, N'Ugnayan Payment Center', N'Bills payment network', N'UPC45', N'Michelle B. Soriano', N'16 Gen. Luna St.', 750, 120),
    (46, N'Pag-asa Rural Bank of Iloilo', N'Rural bank partner', N'PRB46', N'Romeo D. Magbanua', N'21 Iznart St.', 750, 95),
    (47, N'Dagat Fishermen''s Cooperative', N'Fisherfolk cooperative; group accident and boat cover', N'DFC47', N'Wilfredo N. Domingo', N'Purok 3, Coastal Rd.', 2108, 70),
    (48, N'Sinag Solar Financing', N'Solar equipment financing partner', N'SSF48', N'Patricia L. Ramirez', N'4 Lopez Jaena St.', 2061, 45),
    (49, N'Bukid Agri Lending', N'Agricultural lending partner', N'BAL49', N'Gerardo S. Pangilinan', N'27 Maharlika Hwy.', 2035, 25),
    (50, N'Talaan Remittance Hub', N'Remittance partner in Visayas', N'TRH50', N'Lourdes V. Fernandez', N'9 Gorordo Ave.', 2075, 10)
) AS v ([Seed], [Name], [Description], [Code], [ContactPerson], [Address1], [CityId], [DaysAgo])
CROSS APPLY (SELECT TOP (1) tw.[Id] FROM [Static].[AddressTown] AS tw WHERE tw.[AddressCityId] = v.[CityId] ORDER BY tw.[Id]) AS t
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[Partners] AS x WHERE x.[Code] = v.[Code]);

INSERT INTO [Reference].[Providers]
    ([Name], [Description], [Code], [ContactPerson], [EmailAddress], [ContactNumber], [Address1], [Address2], [AddressTownId], [IsActive], [CreatedDateTime], [ModifiedDateTime])
SELECT v.[Name], v.[Description], v.[Code], v.[ContactPerson], CONCAT(N'underwriting.', LOWER(v.[Code]), N'@example.com'),
       CONCAT(N'+6392', RIGHT(CONCAT(N'00000000', v.[Seed] * 6151 % 100000000), 8)), v.[Address1], v.[Address2], t.[Id], 1,
       DATEADD(DAY, -v.[DaysAgo], CAST(@Today AS datetime2(7))), DATEADD(DAY, -v.[DaysAgo], CAST(@Today AS datetime2(7)))
FROM (VALUES
    (21, N'Bayanihan General Insurance Corp.', N'Non-life insurer: motor, fire and personal accident', N'BGI21', N'Eduardo P. Santiago', N'Bayanihan Tower, 6780 Ayala Ave.', N'18th Floor', 2002, 1100),
    (22, N'Kalasag Life Assurance', N'Life insurer: credit life and group term life', N'KLA22', N'Mary Grace T. Rivera', N'Kalasag Building, 32nd St.', N'12th Floor', 2003, 1090),
    (23, N'Tanglaw Mutual Benefit Association', N'Microinsurance MBA for microfinance clients', N'TMB23', N'Rogelio A. Castro', N'15 Kamuning Rd.', NULL, 2001, 1060),
    (24, N'Habagat Insurance Co.', N'Non-life insurer: property and engineering', N'HIC24', N'Leonora C. Bautista', N'Habagat Centre, Ortigas Ave.', N'9th Floor', 2004, 1000),
    (25, N'Amihan Health Care', N'HMO for group health plans', N'AHC25', N'Joshua R. Perez', N'Amihan Plaza, Shaw Blvd.', N'5th Floor', 2005, 950),
    (26, N'Sandigan Surety and Insurance', N'Surety bonds and guaranty', N'SSI26', N'Divina M. Hernandez', N'210 Gil Puyat Ave.', N'7th Floor', 2002, 900),
    (27, N'Bantay Buhay Life Insurance', N'Life insurer: individual and family plans', N'BBL27', N'Francis G. Torres', N'Bantay Buhay Building, Osmeña Blvd.', NULL, 2075, 850),
    (28, N'Kanlungan Health Plans', N'HMO for individual health plans', N'KHP28', N'Precious L. Gomez', N'88 J.P. Laurel Ave.', N'3rd Floor', 2101, 800),
    (29, N'Malasakit Microinsurance MBA', N'Microinsurance MBA for cooperatives', N'MMI29', N'Renato S. Aquino', N'4 Magsaysay Ave.', NULL, 2063, 760),
    (30, N'Tibay Fire and Marine Insurance', N'Fire, marine cargo and hull', N'TFM30', N'Elena V. Domingo', N'Tibay Building, Port Area', N'2nd Floor', 1350, 700),
    (31, N'Lakbay Travel Assurance', N'Travel insurance underwriter', N'LTA31', N'Kenneth B. Villanueva', N'Lakbay Tower, Macapagal Blvd.', N'11th Floor', 2007, 640),
    (32, N'Kalinga Pre-Need Corp.', N'Pre-need memorial and education plans', N'KPN32', N'Remedios F. Garcia', N'35 Rizal St.', NULL, 2069, 560),
    (33, N'Sigla Health Maintenance Inc.', N'HMO for SMEs', N'SHM33', N'Christian J. Lopez', N'Sigla Center, Lahug', N'4th Floor', 2075, 480),
    (34, N'Pundasyon Engineering Insurance', N'Contractors all risk and erection all risk', N'PEI34', N'Andrea N. Reyes', N'Pundasyon Building, Pasig Blvd.', N'6th Floor', 2004, 390),
    (35, N'Daungan Marine Underwriters', N'Marine hull and cargo underwriter', N'DMU35', N'Arturo E. Cruz', N'12 Pier Rd.', NULL, 2093, 300)
) AS v ([Seed], [Name], [Description], [Code], [ContactPerson], [Address1], [Address2], [CityId], [DaysAgo])
CROSS APPLY (SELECT TOP (1) tw.[Id] FROM [Static].[AddressTown] AS tw WHERE tw.[AddressCityId] = v.[CityId] ORDER BY tw.[Id]) AS t
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[Providers] AS x WHERE x.[Code] = v.[Code]);
GO

/* ---------- Product set-up for every product: benefits for the products the mock data left without any, and deductibles ---------- */

INSERT INTO [Reference].[ProductBenefits] ([ProductsId], [BenefitsId], [CoverageAmount], [PremiumAmount], [PremiumCommissionAmount])
SELECT v.[ProductsId], v.[BenefitsId], v.[CoverageAmount], v.[PremiumAmount], v.[PremiumCommissionAmount]
FROM (VALUES
    (27, 84, 900000.00, 18500.00, 1850.00), (27, 22, 200000.00, 950.00, 95.00), (27, 59, 500000.00, 1450.00, 145.00),
    (28, 84, 1200000.00, 23800.00, 2380.00), (28, 22, 200000.00, 950.00, 95.00), (28, 59, 750000.00, 1950.00, 195.00),
    (29, 84, 1800000.00, 34500.00, 3450.00), (29, 22, 200000.00, 950.00, 95.00), (29, 59, 1000000.00, 2450.00, 245.00),
    (30, 84, 90000.00, 2800.00, 280.00), (30, 22, 100000.00, 450.00, 45.00),
    (76, 1, 50000.00, 45.00, 4.50), (76, 2, 50000.00, 0.00, 0.00), (76, 4, 5000.00, 8.00, 0.80),
    (77, 1, 30000.00, 30.00, 3.00), (77, 2, 30000.00, 0.00, 0.00), (77, 28, 10000.00, 25.00, 2.50),
    (93, 1, 50000.00, 45.00, 4.50), (93, 2, 50000.00, 0.00, 0.00), (93, 4, 5000.00, 8.00, 0.80),
    (90, 60, 1000000.00, 1850.00, 185.00), (90, 4, 10000.00, 25.00, 2.50),
    (91, 105, 1000000.00, 3500.00, 350.00), (91, 103, 2000000.00, 7800.00, 780.00),
    (143, 103, 5000000.00, 18500.00, 1850.00), (143, 114, 1000000.00, 2500.00, 250.00),
    (144, 105, 3000000.00, 9000.00, 900.00),
    (96, 66, 1000000.00, 4500.00, 450.00), (97, 20, 500000.00, 2200.00, 220.00), (98, 66, 500000.00, 2500.00, 250.00), (99, 113, 1000000.00, 5000.00, 500.00),
    (135, 66, 50000.00, 650.00, 65.00), (136, 66, 100000.00, 1100.00, 110.00), (138, 66, 300000.00, 2600.00, 260.00), (139, 66, 400000.00, 3300.00, 330.00),
    (100, 42, 100000.00, 1200.00, 120.00), (100, 14, 20000.00, 300.00, 30.00), (142, 42, 100000.00, 1200.00, 120.00), (142, 14, 20000.00, 300.00, 30.00),
    (102, 1, 50000.00, 60.00, 6.00), (102, 30, 10000.00, 25.00, 2.50), (102, 79, 5000.00, 15.00, 1.50),
    (103, 1, 100000.00, 95.00, 9.50), (103, 30, 20000.00, 40.00, 4.00), (103, 79, 10000.00, 20.00, 2.00),
    (104, 1, 500000.00, 300.00, 30.00), (104, 30, 50000.00, 90.00, 9.00), (104, 79, 20000.00, 35.00, 3.50), (104, 76, 20000.00, 45.00, 4.50),
    (105, 1, 750000.00, 420.00, 42.00), (105, 30, 75000.00, 120.00, 12.00), (105, 79, 25000.00, 40.00, 4.00), (105, 76, 25000.00, 55.00, 5.50),
    (106, 1, 1000000.00, 550.00, 55.00), (106, 30, 100000.00, 150.00, 15.00), (106, 79, 30000.00, 45.00, 4.50), (106, 76, 30000.00, 65.00, 6.50),
    (108, 1, 1000000.00, 900.00, 90.00), (108, 92, 1000000.00, 1500.00, 150.00), (108, 69, 1000000.00, 450.00, 45.00), (108, 93, 50000.00, 250.00, 25.00), (108, 94, 25000.00, 120.00, 12.00),
    (109, 1, 2500000.00, 1500.00, 150.00), (109, 92, 2500000.00, 2600.00, 260.00), (109, 69, 2500000.00, 800.00, 80.00), (109, 93, 75000.00, 350.00, 35.00), (109, 94, 30000.00, 150.00, 15.00),
    (110, 1, 5000000.00, 2400.00, 240.00), (110, 92, 5000000.00, 4300.00, 430.00), (110, 69, 5000000.00, 1300.00, 130.00), (110, 93, 100000.00, 450.00, 45.00), (110, 94, 40000.00, 180.00, 18.00),
    (115, 23, 50000.00, 950.00, 95.00), (115, 48, 5000.00, 50.00, 5.00),
    (141, 8, 100000.00, 350.00, 35.00), (141, 5, 100000.00, 120.00, 12.00)
) AS v ([ProductsId], [BenefitsId], [CoverageAmount], [PremiumAmount], [PremiumCommissionAmount])
WHERE EXISTS (SELECT 1 FROM [Reference].[Products] AS p WHERE p.[Id] = v.[ProductsId])
  AND EXISTS (SELECT 1 FROM [Reference].[Benefits] AS b WHERE b.[Id] = v.[BenefitsId])
  AND NOT EXISTS (SELECT 1 FROM [Reference].[ProductBenefits] AS x WHERE x.[ProductsId] = v.[ProductsId] AND x.[BenefitsId] = v.[BenefitsId]);

INSERT INTO [Reference].[ProductDeductibles] ([ProductsId], [DeductiblesId], [Amount])
SELECT p.[Id], d.[DeductiblesId], d.[Amount]
FROM [Reference].[Products] AS p
INNER JOIN (VALUES
    (5, 1, 2000.00), (5, 2, 5000.00), (5, 3, 1000.00),
    (6, 13, 5000.00), (6, 14, 25000.00), (6, 15, 15000.00), (6, 16, 15000.00), (6, 18, 5000.00),
    (7, 19, 10000.00), (7, 21, 20000.00), (7, 22, 15000.00),
    (8, 9, 5000.00), (8, 12, 5000.00), (8, 19, 10000.00),
    (9, 1, 25000.00), (9, 2, 50000.00),
    (13, 1, 50000.00), (13, 14, 100000.00), (13, 15, 75000.00)
) AS d ([ProductCategoryId], [DeductiblesId], [Amount]) ON d.[ProductCategoryId] = p.[ProductCategoryId]
WHERE NOT EXISTS (SELECT 1 FROM [Reference].[ProductDeductibles] AS x WHERE x.[ProductsId] = p.[Id] AND x.[DeductiblesId] = d.[DeductiblesId]);
GO

/* ---------- Policy bookings with beneficiaries, benefits, deductibles, payments and attachments ----------
   Runs once: skipped when bookings for the generated clients already exist. */

IF NOT EXISTS
(
    SELECT 1
    FROM [Transaction].[IndividualPolicy] AS p
    INNER JOIN [Reference].[Clients] AS c ON c.[Id] = p.[ClientsId]
    WHERE c.[InsuranceCustomerNo] LIKE N'INSC2%'
)
BEGIN
    DECLARE @Now datetime2(7) = SYSUTCDATETIME();
    DECLARE @Today date = CAST(@Now AS date);
    DECLARE @UserId bigint = 500329;

    DROP TABLE IF EXISTS #Pool;
    DROP TABLE IF EXISTS #ProductPool;
    DROP TABLE IF EXISTS #P;
    DROP TABLE IF EXISTS #NewPayments;

    CREATE TABLE #Pool ([Kind] nvarchar(10) NOT NULL, [K] int NOT NULL, [Id] bigint NOT NULL, [AgentsId] bigint NULL, [Code] nvarchar(30) NULL, PRIMARY KEY ([Kind], [K]));

    INSERT INTO #Pool SELECT N'CLI', ROW_NUMBER() OVER (ORDER BY [Id]) - 1, [Id], NULL, NULL FROM [Reference].[Clients] WHERE [IsActive] = 1 AND [IsDeleted] = 0;
    INSERT INTO #Pool SELECT N'PAR', ROW_NUMBER() OVER (ORDER BY [Id]) - 1, [Id], NULL, [Code] FROM [Reference].[Partners] WHERE [IsActive] = 1 AND [IsDeleted] = 0;
    INSERT INTO #Pool SELECT N'PRV', ROW_NUMBER() OVER (ORDER BY [Id]) - 1, [Id], NULL, [Code] FROM [Reference].[Providers] WHERE [IsActive] = 1 AND [IsDeleted] = 0;
    INSERT INTO #Pool SELECT N'AGT', ROW_NUMBER() OVER (ORDER BY [Id]) - 1, [Id], NULL, NULL FROM [Reference].[Agents] WHERE [IsActive] = 1 AND [IsDeleted] = 0;
    INSERT INTO #Pool SELECT N'SAG', ROW_NUMBER() OVER (ORDER BY [Id]) - 1, [Id], NULL, NULL FROM [Reference].[SubAgents] WHERE [IsActive] = 1 AND [IsDeleted] = 0;
    INSERT INTO #Pool SELECT N'APR', ROW_NUMBER() OVER (ORDER BY [Id]) - 1, [Id], NULL, NULL FROM [Reference].[Approvers] WHERE [IsActive] = 1 AND [IsDeleted] = 0;
    INSERT INTO #Pool SELECT N'PMG', ROW_NUMBER() OVER (ORDER BY [Id]) - 1, [Id], [AgentsId], NULL FROM [Reference].[PromoManagers] WHERE [IsActive] = 1 AND [IsDeleted] = 0;
    INSERT INTO #Pool SELECT N'POF', ROW_NUMBER() OVER (ORDER BY [Id]) - 1, [Id], [AgentsId], NULL FROM [Reference].[PromoOfficers] WHERE [IsActive] = 1 AND [IsDeleted] = 0;
    INSERT INTO #Pool SELECT N'SMG', ROW_NUMBER() OVER (ORDER BY [Id]) - 1, [Id], [AgentsId], NULL FROM [Reference].[SalesManagers] WHERE [IsActive] = 1 AND [IsDeleted] = 0;
    INSERT INTO #Pool SELECT N'DCH', ROW_NUMBER() OVER (ORDER BY [Id]) - 1, [Id], NULL, NULL FROM [Reference].[DistributionChannel] WHERE [IsActive] = 1 AND [IsDeleted] = 0;

    /* Individual and partner bookings use retail products, group bookings use group, business and bond products. */
    SELECT x.[PolicyTypeId], CAST(ROW_NUMBER() OVER (PARTITION BY x.[PolicyTypeId] ORDER BY p.[Id]) - 1 AS int) AS [K], p.[Id], p.[ProductCategoryId]
    INTO #ProductPool
    FROM [Reference].[Products] AS p
    CROSS JOIN (VALUES (1), (2), (3)) AS x ([PolicyTypeId])
    WHERE p.[IsActive] = 1 AND p.[IsDeleted] = 0
      AND EXISTS (SELECT 1 FROM [Reference].[ProductBenefits] AS pb WHERE pb.[ProductsId] = p.[Id] AND pb.[IsActive] = 1)
      AND (   (x.[PolicyTypeId] = 1 AND p.[ProductCategoryId] IN (3, 4, 5, 6, 8, 10, 11, 14))
           OR (x.[PolicyTypeId] = 2 AND p.[ProductCategoryId] IN (3, 4, 10, 11, 14, 15))
           OR (x.[PolicyTypeId] = 3 AND p.[ProductCategoryId] IN (1, 2, 7, 9, 12, 13)));

    CREATE TABLE #P
    (
        [N] int NOT NULL PRIMARY KEY, [PolicyTypeId] bigint NOT NULL, [CreatedDateTime] datetime2(7) NOT NULL,
        [ProductsId] bigint NULL, [ProductCategoryId] bigint NULL, [ClientsId] bigint NULL, [PartnersId] bigint NULL, [PlatformsId] bigint NULL,
        [IssueStatus] bit NULL, [PolicyBookingStatusId] bigint NULL, [CocStatusId] bigint NULL, [ClaimsStatusId] bigint NULL,
        [AgentsId] bigint NULL, [SubAgentsId] bigint NULL, [ApproversId] bigint NULL, [PromoManagersId] bigint NULL, [SalesManagersId] bigint NULL, [PromoOfficersId] bigint NULL,
        [ProvidersId] bigint NULL, [DistributionChannelId] bigint NULL, [PaymentOptionId] bigint NULL, [AccountTypeId] bigint NULL,
        [BranchCode] nvarchar(5) NULL, [BranchName] nvarchar(6) NULL, [ProviderPolicyNo] nvarchar(50) NULL, [EndorsementNo] nvarchar(50) NULL,
        [EffectiveDate] date NULL, [TerminationDate] date NULL, [IssueDate] date NULL, [Remarks] nvarchar(500) NULL,
        [Members] int NOT NULL DEFAULT (1), [Base] decimal(18, 2) NULL,
        [BasicPremium] decimal(18, 2) NULL, [BasicPremiumCommission] decimal(18, 2) NULL, [DJDPatricioMarkup] decimal(18, 2) NULL, [PartnerMarkup] decimal(18, 2) NULL,
        [Discount] decimal(18, 2) NULL, [Taxes] decimal(18, 2) NULL, [DST] decimal(18, 2) NULL, [VAT] decimal(18, 2) NULL, [LGT] decimal(18, 2) NULL, [PT] decimal(18, 2) NULL,
        [FST] decimal(18, 2) NULL, [NotarialFee] decimal(18, 2) NULL, [Others] decimal(18, 2) NULL, [PremiumsRemarks] nvarchar(500) NULL,
        [PaymentPlan] int NULL, [ReferenceNumber] nvarchar(12) NULL, [CocNumber] nvarchar(12) NULL, [PolicyId] bigint NULL, [TotalPremium] decimal(18, 2) NULL
    );

    /* 300 individual, 120 partner and 80 group bookings over the last 1,060 days (three calendar years and part of a fourth),
       with volume growing steadily towards today, during Philippine office hours (00:00 to 09:00 UTC). */
    INSERT INTO #P ([N], [PolicyTypeId], [CreatedDateTime])
    SELECT
        n.[N],
        CASE WHEN n.[N] <= 300 THEN 1 WHEN n.[N] <= 420 THEN 2 ELSE 3 END,
        DATEADD(MINUTE, (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', n.[N], 4)) AS binary(4)) AS int) & 2147483647) % 540,
            CAST(DATEADD(DAY, -(1059 - CAST(FLOOR(SQRT((CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', n.[N], 1)) AS binary(4)) AS int) & 2147483647) % 1123600)) AS int)), @Today) AS datetime2(7)))
    FROM #Numbers AS n
    WHERE n.[N] <= 500;

    UPDATE #P SET [CreatedDateTime] = DATEADD(MINUTE, -(1 + [N] % 300), @Now) WHERE [CreatedDateTime] > @Now;

    UPDATE p
    SET [PolicyBookingStatusId] = CASE WHEN h.[V] < 45 THEN 1 WHEN h.[V] < 60 THEN 7 WHEN h.[V] < 72 THEN 3 WHEN h.[V] < 80 THEN 5 WHEN h.[V] < 85 THEN 6 WHEN h.[V] < 93 THEN 2 ELSE 4 END,
        [ProductsId] = pp.[Id],
        [ProductCategoryId] = pp.[ProductCategoryId],
        [ClientsId] = CASE WHEN p.[PolicyTypeId] = 1 THEN (SELECT x.[Id] FROM #Pool AS x WHERE x.[Kind] = N'CLI' AND x.[K] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 8)) AS binary(4)) AS int) & 2147483647) % (SELECT COUNT(*) FROM #Pool WHERE [Kind] = N'CLI')) END,
        [PartnersId] = (SELECT x.[Id] FROM #Pool AS x WHERE x.[Kind] = N'PAR' AND x.[K] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 9)) AS binary(4)) AS int) & 2147483647) % (SELECT COUNT(*) FROM #Pool WHERE [Kind] = N'PAR')),
        [ProvidersId] = (SELECT x.[Id] FROM #Pool AS x WHERE x.[Kind] = N'PRV' AND x.[K] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 10)) AS binary(4)) AS int) & 2147483647) % (SELECT COUNT(*) FROM #Pool WHERE [Kind] = N'PRV')),
        [AgentsId] = (SELECT x.[Id] FROM #Pool AS x WHERE x.[Kind] = N'AGT' AND x.[K] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 11)) AS binary(4)) AS int) & 2147483647) % (SELECT COUNT(*) FROM #Pool WHERE [Kind] = N'AGT')),
        [ApproversId] = (SELECT x.[Id] FROM #Pool AS x WHERE x.[Kind] = N'APR' AND x.[K] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 12)) AS binary(4)) AS int) & 2147483647) % (SELECT COUNT(*) FROM #Pool WHERE [Kind] = N'APR')),
        [DistributionChannelId] = (SELECT x.[Id] FROM #Pool AS x WHERE x.[Kind] = N'DCH' AND x.[K] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 13)) AS binary(4)) AS int) & 2147483647) % (SELECT COUNT(*) FROM #Pool WHERE [Kind] = N'DCH')),
        [PlatformsId] = CASE WHEN (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 14)) AS binary(4)) AS int) & 2147483647) % 100 < 55 THEN 27 ELSE (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 15)) AS binary(4)) AS int) & 2147483647) % 26 + 1 END,
        [PaymentOptionId] = 27 + (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 16)) AS binary(4)) AS int) & 2147483647) % 7,
        [AccountTypeId] = CASE WHEN p.[PolicyTypeId] = 3 THEN 23 + (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 17)) AS binary(4)) AS int) & 2147483647) % 4 END,
        [Members] = CASE WHEN p.[PolicyTypeId] = 3 THEN 10 + (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 18)) AS binary(4)) AS int) & 2147483647) % 91 ELSE 1 END,
        [IssueDate] = CAST(p.[CreatedDateTime] AS date),
        [EffectiveDate] = DATEADD(DAY, (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 19)) AS binary(4)) AS int) & 2147483647) % 10, CAST(p.[CreatedDateTime] AS date)),
        [Remarks] = CASE (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 20)) AS binary(4)) AS int) & 2147483647) % 7
            WHEN 0 THEN N'Walk-in client' WHEN 1 THEN N'Renewal from previous year' WHEN 2 THEN N'Referred by partner branch'
            WHEN 3 THEN N'Booked through mobile app' WHEN 4 THEN CASE WHEN p.[PolicyTypeId] = 3 THEN N'Bulk enrollment of members' END END,
        [PaymentPlan] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 21)) AS binary(4)) AS int) & 2147483647) % 10
    FROM #P AS p
    CROSS APPLY (SELECT (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 6)) AS binary(4)) AS int) & 2147483647) % 100 AS [V]) AS h
    INNER JOIN #ProductPool AS pp
        ON pp.[PolicyTypeId] = p.[PolicyTypeId]
       AND pp.[K] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 7)) AS binary(4)) AS int) & 2147483647) % (SELECT COUNT(*) FROM #ProductPool AS c WHERE c.[PolicyTypeId] = p.[PolicyTypeId]);

    /* Mall branch channels (7, 8) carry promo and sales managers under the managing agent; the others may carry a sub-agent. */
    UPDATE p
    SET [PromoManagersId] = CASE WHEN p.[DistributionChannelId] IN (7, 8) THEN pm.[Id] END,
        [AgentsId] = CASE WHEN p.[DistributionChannelId] IN (7, 8) THEN pm.[AgentsId] ELSE p.[AgentsId] END,
        [SalesManagersId] = CASE WHEN p.[DistributionChannelId] IN (7, 8) THEN sm.[Id] END,
        [PromoOfficersId] = CASE WHEN p.[DistributionChannelId] IN (7, 8) AND p.[N] % 3 <> 0 THEN po.[Id] END,
        [SubAgentsId] = CASE WHEN p.[DistributionChannelId] NOT IN (7, 8) AND p.[N] % 3 <> 0 THEN sa.[Id] END,
        [BranchCode] = CASE WHEN p.[PolicyTypeId] = 3 AND p.[DistributionChannelId] = 4 THEN RIGHT(CONCAT(N'00000', (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 22)) AS binary(4)) AS int) & 2147483647) % 100000), 5) END,
        [BranchName] = CASE WHEN p.[PolicyTypeId] = 3 AND p.[DistributionChannelId] = 4 THEN RIGHT(CONCAT(N'000000', (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 23)) AS binary(4)) AS int) & 2147483647) % 1000000), 6) END,
        [TerminationDate] = CASE WHEN p.[ProductCategoryId] = 11 THEN DATEADD(DAY, 7 + (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 24)) AS binary(4)) AS int) & 2147483647) % 24, p.[EffectiveDate])
                                 ELSE DATEADD(DAY, -1, DATEADD(YEAR, 1, p.[EffectiveDate])) END,
        [ProviderPolicyNo] = CONCAT(prv.[Code], N'-', YEAR(p.[CreatedDateTime]), N'-', RIGHT(CONCAT(N'000000', p.[N]), 6)),
        [EndorsementNo] = CASE WHEN p.[N] % 4 = 0 THEN CONCAT(N'EN-', YEAR(p.[CreatedDateTime]), N'-', RIGHT(CONCAT(N'0000', p.[N]), 4)) END
    FROM #P AS p
    INNER JOIN #Pool AS prv ON prv.[Kind] = N'PRV' AND prv.[Id] = p.[ProvidersId]
    LEFT JOIN #Pool AS pm ON pm.[Kind] = N'PMG' AND pm.[K] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 25)) AS binary(4)) AS int) & 2147483647) % (SELECT COUNT(*) FROM #Pool WHERE [Kind] = N'PMG')
    LEFT JOIN #Pool AS sm ON sm.[Kind] = N'SMG' AND sm.[K] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 26)) AS binary(4)) AS int) & 2147483647) % (SELECT COUNT(*) FROM #Pool WHERE [Kind] = N'SMG')
    LEFT JOIN #Pool AS po ON po.[Kind] = N'POF' AND po.[K] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 27)) AS binary(4)) AS int) & 2147483647) % (SELECT COUNT(*) FROM #Pool WHERE [Kind] = N'POF')
    LEFT JOIN #Pool AS sa ON sa.[Kind] = N'SAG' AND sa.[K] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 28)) AS binary(4)) AS int) & 2147483647) % (SELECT COUNT(*) FROM #Pool WHERE [Kind] = N'SAG');

    /* Statuses: approved bookings are active until they lapse, a few are claimed or cancelled; open bookings keep an inactive COC; rejected ones are void. */
    UPDATE #P
    SET [IssueStatus] = CASE WHEN [PolicyBookingStatusId] IN (2, 4) THEN 0 ELSE 1 END,
        [CocStatusId] = CASE
            WHEN [PolicyBookingStatusId] IN (2, 4) THEN 5
            WHEN [PolicyBookingStatusId] IN (3, 5, 6) THEN 6
            WHEN [TerminationDate] < @Today THEN 3
            WHEN [N] % 25 = 0 THEN 4
            WHEN [N] % 17 = 0 THEN 2
            ELSE 1 END;

    UPDATE #P
    SET [ClaimsStatusId] = CASE
            WHEN [CocStatusId] = 2 THEN 10
            WHEN [PolicyBookingStatusId] IN (1, 7) AND [N] % 7 = 0 THEN (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', [N], 29)) AS binary(4)) AS int) & 2147483647) % 23 + 1
            ELSE 3 END,
        [PaymentPlan] = CASE
            WHEN [CocStatusId] = 4 THEN 1
            WHEN [PolicyBookingStatusId] IN (1, 7) THEN CASE WHEN [PaymentPlan] <= 5 THEN 1 WHEN [PaymentPlan] = 6 THEN 2 WHEN [PaymentPlan] = 7 THEN 3 WHEN [PaymentPlan] = 8 THEN 4 ELSE 0 END
            WHEN [PolicyBookingStatusId] = 3 AND [N] % 3 = 0 THEN 3
            ELSE 0 END;

    /* Premium charges in PHP: basic premium plus markups, documentary stamp tax, VAT (non-life), premium tax (life), local and fire service taxes. */
    UPDATE p
    SET [Base] = CASE
            WHEN p.[PolicyTypeId] = 3 THEN p.[Members] * (80 + (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 30)) AS binary(4)) AS int) & 2147483647) % 220)
            WHEN p.[ProductCategoryId] IN (5, 6) THEN 3000 + (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 30)) AS binary(4)) AS int) & 2147483647) % 22000
            ELSE 100 + (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 30)) AS binary(4)) AS int) & 2147483647) % 2900 END
    FROM #P AS p;

    UPDATE #P
    SET [BasicPremium] = [Base],
        [BasicPremiumCommission] = ROUND([Base] * 0.15, 2),
        [DJDPatricioMarkup] = ROUND([Base] * 0.05, 2),
        [PartnerMarkup] = ROUND([Base] * CASE WHEN [PolicyTypeId] = 2 THEN 0.08 ELSE 0.02 END, 2),
        [Discount] = CASE WHEN [N] % 7 = 0 THEN ROUND([Base] * 0.05, 2) ELSE 0 END,
        [Taxes] = 0,
        [DST] = ROUND([Base] * 0.125, 2),
        [VAT] = CASE WHEN [ProductCategoryId] = 14 THEN 0 ELSE ROUND([Base] * 0.12, 2) END,
        [LGT] = ROUND([Base] * 0.005, 2),
        [PT] = CASE WHEN [ProductCategoryId] = 14 THEN ROUND([Base] * 0.02, 2) ELSE 0 END,
        [FST] = ROUND([Base] * 0.002, 2),
        [NotarialFee] = CASE WHEN [PolicyTypeId] = 3 THEN 100 ELSE 0 END,
        [Others] = 0,
        [PremiumsRemarks] = CASE WHEN [N] % 7 = 0 THEN N'5% loyalty discount applied' END;

    /* Reference and COC numbers continue after the highest existing numbers; COC numbers follow booking time across all policy types. */
    DECLARE @IndividualBase bigint = ISNULL((SELECT MAX(TRY_CAST(RIGHT([ReferenceNumber], 9) AS bigint)) FROM [Transaction].[IndividualPolicy]), 0);
    DECLARE @PartnerBase bigint = ISNULL((SELECT MAX(TRY_CAST(RIGHT([ReferenceNumber], 9) AS bigint)) FROM [Transaction].[PartnerPolicy]), 0);
    DECLARE @GroupBase bigint = ISNULL((SELECT MAX(TRY_CAST(RIGHT([ReferenceNumber], 9) AS bigint)) FROM [Transaction].[GroupPolicy]), 0);
    DECLARE @CocBase bigint = ISNULL((SELECT MAX(x.[Coc]) FROM (
        SELECT TRY_CAST([CocNumber] AS bigint) AS [Coc] FROM [Transaction].[IndividualPolicy]
        UNION ALL SELECT TRY_CAST([CocNumber] AS bigint) FROM [Transaction].[PartnerPolicy]
        UNION ALL SELECT TRY_CAST([CocNumber] AS bigint) FROM [Transaction].[GroupPolicy]) AS x), 0);

    WITH [Numbered] AS
    (
        SELECT [ReferenceNumber], [CocNumber], [PolicyTypeId],
               ROW_NUMBER() OVER (PARTITION BY [PolicyTypeId] ORDER BY [CreatedDateTime], [N]) AS [TypeNumber],
               ROW_NUMBER() OVER (ORDER BY [CreatedDateTime], [N]) AS [CocNumberInRun]
        FROM #P
    )
    UPDATE [Numbered]
    SET [ReferenceNumber] = [Transaction].[FormatReferenceNumber]([PolicyTypeId],
            [TypeNumber] + CASE [PolicyTypeId] WHEN 1 THEN @IndividualBase WHEN 2 THEN @PartnerBase ELSE @GroupBase END),
        [CocNumber] = [Transaction].[FormatCocNumber]([CocNumberInRun] + @CocBase);

    INSERT INTO [Transaction].[IndividualPolicy]
    (
        [ReferenceNumber], [CocNumber], [ClientsId], [PartnersId], [PlatformsId], [IssueStatus], [PolicyBookingStatusId], [CocStatusId], [PaymentStatusId], [ClaimsStatusId],
        [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId], [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId],
        [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks],
        [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes], [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks],
        [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime]
    )
    SELECT
        [ReferenceNumber], [CocNumber], [ClientsId], [PartnersId], [PlatformsId], [IssueStatus], [PolicyBookingStatusId], [CocStatusId], 2, [ClaimsStatusId],
        [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId], [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId],
        [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks],
        [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes], [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks],
        @UserId, [CreatedDateTime], @UserId, [CreatedDateTime]
    FROM #P
    WHERE [PolicyTypeId] = 1
    ORDER BY [ReferenceNumber];

    INSERT INTO [Transaction].[PartnerPolicy]
    (
        [ReferenceNumber], [CocNumber], [PartnersId], [PlatformsId], [IssueStatus], [PolicyBookingStatusId], [CocStatusId], [PaymentStatusId], [ClaimsStatusId],
        [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId], [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId],
        [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks],
        [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes], [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks],
        [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime]
    )
    SELECT
        [ReferenceNumber], [CocNumber], [PartnersId], [PlatformsId], [IssueStatus], [PolicyBookingStatusId], [CocStatusId], 2, [ClaimsStatusId],
        [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId], [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId],
        [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks],
        [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes], [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks],
        @UserId, [CreatedDateTime], @UserId, [CreatedDateTime]
    FROM #P
    WHERE [PolicyTypeId] = 2
    ORDER BY [ReferenceNumber];

    INSERT INTO [Transaction].[GroupPolicy]
    (
        [ReferenceNumber], [CocNumber], [PartnersId], [PlatformsId], [IssueStatus], [PolicyBookingStatusId], [CocStatusId], [PaymentStatusId], [ClaimsStatusId],
        [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId], [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId],
        [AccountTypeId], [BranchCode], [BranchName],
        [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks],
        [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes], [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks],
        [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime]
    )
    SELECT
        [ReferenceNumber], [CocNumber], [PartnersId], [PlatformsId], [IssueStatus], [PolicyBookingStatusId], [CocStatusId], 2, [ClaimsStatusId],
        [AgentsId], [SubAgentsId], [ApproversId], [PromoManagersId], [SalesManagersId], [PromoOfficersId], [ProductsId], [ProvidersId], [DistributionChannelId], [PaymentOptionId],
        [AccountTypeId], [BranchCode], [BranchName],
        [ProviderPolicyNo], [EndorsementNo], [TerminationDate], [EffectiveDate], [IssueDate], [Remarks],
        [BasicPremium], [BasicPremiumCommission], [DJDPatricioMarkup], [PartnerMarkup], [Discount], [Taxes], [DST], [VAT], [LGT], [PT], [FST], [NotarialFee], [Others], [PremiumsRemarks],
        @UserId, [CreatedDateTime], @UserId, [CreatedDateTime]
    FROM #P
    WHERE [PolicyTypeId] = 3
    ORDER BY [ReferenceNumber];

    UPDATE p SET [PolicyId] = t.[Id] FROM #P AS p INNER JOIN [Transaction].[IndividualPolicy] AS t ON t.[ReferenceNumber] = p.[ReferenceNumber] WHERE p.[PolicyTypeId] = 1;
    UPDATE p SET [PolicyId] = t.[Id] FROM #P AS p INNER JOIN [Transaction].[PartnerPolicy] AS t ON t.[ReferenceNumber] = p.[ReferenceNumber] WHERE p.[PolicyTypeId] = 2;
    UPDATE p SET [PolicyId] = t.[Id] FROM #P AS p INNER JOIN [Transaction].[GroupPolicy] AS t ON t.[ReferenceNumber] = p.[ReferenceNumber] WHERE p.[PolicyTypeId] = 3;

    /* Benefits come from the product set-up; group premiums scale with the number of members. */
    INSERT INTO [Transaction].[PolicyBenefits]
        ([PolicyId], [PolicyTypeId], [BenefitsId], [CoverageAmount], [PremiumAmount], [PremiumCommissionAmount], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
    SELECT p.[PolicyId], p.[PolicyTypeId], pb.[BenefitsId], pb.[CoverageAmount], pb.[PremiumAmount] * p.[Members], pb.[PremiumCommissionAmount] * p.[Members],
           @UserId, p.[CreatedDateTime], @UserId, p.[CreatedDateTime]
    FROM #P AS p
    INNER JOIN [Reference].[ProductBenefits] AS pb ON pb.[ProductsId] = p.[ProductsId] AND pb.[IsActive] = 1 AND pb.[IsDeleted] = 0
    ORDER BY p.[PolicyTypeId], p.[PolicyId], pb.[Id];

    INSERT INTO [Transaction].[PolicyDeductibles]
        ([PolicyId], [PolicyTypeId], [DeductiblesId], [Amount], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
    SELECT p.[PolicyId], p.[PolicyTypeId], pd.[DeductiblesId], pd.[Amount], @UserId, p.[CreatedDateTime], @UserId, p.[CreatedDateTime]
    FROM #P AS p
    INNER JOIN [Reference].[ProductDeductibles] AS pd ON pd.[ProductsId] = p.[ProductsId] AND pd.[IsActive] = 1 AND pd.[IsDeleted] = 0
    ORDER BY p.[PolicyTypeId], p.[PolicyId], pd.[Id];

    /* Beneficiaries: family members of the insured, mostly spouse, children and parents. */
    INSERT INTO [Transaction].[PolicyBeneficiary]
        ([PolicyId], [PolicyTypeId], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [ContactNumber], [DateOfBirth], [Relationship],
         [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
    SELECT
        p.[PolicyId], p.[PolicyTypeId], f.[Name], CASE WHEN (p.[N] + b.[N]) % 4 = 0 THEN NULL ELSE m.[Name] END, ISNULL(cl.[LastName], l.[Name]), NULL,
        LOWER(CONCAT(REPLACE(f.[Name], N' ', N''), N'.', REPLACE(ISNULL(cl.[LastName], l.[Name]), N' ', N''), p.[N], b.[N], N'@example.com')),
        CONCAT(N'+639', RIGHT(CONCAT(N'000000000', (CAST(p.[N] AS bigint) * 6007 + b.[N] * 811 + 170000000) % 1000000000), 9)),
        CASE r.[Relationship]
            WHEN 8 THEN DATEADD(DAY, -((CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], b.[N], 31)) AS binary(4)) AS int) & 2147483647) % 6000), CAST('2021-12-31' AS date))
            WHEN 9 THEN DATEADD(DAY, -((CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], b.[N], 31)) AS binary(4)) AS int) & 2147483647) % 9000), CAST('1972-12-31' AS date))
            ELSE DATEADD(DAY, -((CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], b.[N], 31)) AS binary(4)) AS int) & 2147483647) % 10000), CAST('2000-12-31' AS date)) END,
        r.[Relationship],
        @UserId, p.[CreatedDateTime], @UserId, p.[CreatedDateTime]
    FROM #P AS p
    INNER JOIN #Numbers AS b ON b.[N] <= CASE p.[PolicyTypeId] WHEN 3 THEN 3 WHEN 2 THEN 1 ELSE 1 + CASE WHEN p.[N] % 3 = 0 THEN 1 ELSE 0 END END
    CROSS APPLY (SELECT CASE WHEN (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], b.[N], 32)) AS binary(4)) AS int) & 2147483647) % 10 < 3 THEN 7 WHEN (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], b.[N], 32)) AS binary(4)) AS int) & 2147483647) % 10 < 6 THEN 8
                             WHEN (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], b.[N], 32)) AS binary(4)) AS int) & 2147483647) % 10 < 8 THEN 9 ELSE 10 + (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], b.[N], 33)) AS binary(4)) AS int) & 2147483647) % 13 END AS [Relationship]) AS r
    INNER JOIN #FirstNames AS f ON f.[IsMale] = CAST((p.[N] + b.[N]) % 2 AS bit) AND f.[K] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], b.[N], 34)) AS binary(4)) AS int) & 2147483647) % 40
    INNER JOIN #LastNames AS l ON l.[K] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], b.[N], 35)) AS binary(4)) AS int) & 2147483647) % 60
    INNER JOIN #LastNames AS m ON m.[K] = (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], b.[N], 36)) AS binary(4)) AS int) & 2147483647) % 60
    LEFT JOIN [Reference].[Clients] AS cl ON p.[PolicyTypeId] = 1 AND cl.[Id] = p.[ClientsId] AND r.[Relationship] IN (8, 10)
    ORDER BY p.[PolicyTypeId], p.[PolicyId], b.[N];

    UPDATE p SET [TotalPremium] = t.[TotalPremium]
    FROM #P AS p
    CROSS APPLY [Transaction].[GetPolicyTotals](p.[PolicyTypeId], p.[PolicyId]) AS t;

    /* Payments: plan 1 full, 2 two instalments, 3 partial, 4 overpaid, 0 none. */
    SELECT
        p.[N], p.[PolicyId], p.[PolicyTypeId], i.[N] AS [Instalment],
        CASE
            WHEN p.[PaymentPlan] = 1 THEN p.[TotalPremium]
            WHEN p.[PaymentPlan] = 2 AND i.[N] = 1 THEN ROUND(p.[TotalPremium] / 2, 2)
            WHEN p.[PaymentPlan] = 2 THEN p.[TotalPremium] - ROUND(p.[TotalPremium] / 2, 2)
            WHEN p.[PaymentPlan] = 3 THEN ROUND(p.[TotalPremium] * 0.6, 2)
            ELSE p.[TotalPremium] + 50 END AS [Amount],
        x.[TransactionDateTime],
        CASE WHEN DATEADD(MINUTE, 5 + (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], i.[N], 37)) AS binary(4)) AS int) & 2147483647) % 120, x.[TransactionDateTime]) > @Now THEN @Now
             ELSE DATEADD(MINUTE, 5 + (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], i.[N], 37)) AS binary(4)) AS int) & 2147483647) % 120, x.[TransactionDateTime]) END AS [NotificationDateTime],
        CASE WHEN p.[PaymentPlan] = 2 THEN CASE i.[N] WHEN 1 THEN N'First instalment' ELSE N'Second instalment' END
             WHEN p.[PaymentPlan] = 3 THEN N'Partial payment' WHEN p.[PaymentPlan] = 4 THEN N'Overpayment, excess for refund' END AS [Notes]
    INTO #NewPayments
    FROM #P AS p
    INNER JOIN #Numbers AS i ON i.[N] <= CASE p.[PaymentPlan] WHEN 0 THEN 0 WHEN 2 THEN 2 ELSE 1 END
    CROSS APPLY
    (
        SELECT CASE
            WHEN DATEADD(MINUTE, (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], i.[N], 38)) AS binary(4)) AS int) & 2147483647) % 600, DATEADD(DAY, 1 + (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 39)) AS binary(4)) AS int) & 2147483647) % 5 + (i.[N] - 1) * 30, p.[CreatedDateTime])) > @Now THEN @Now
            ELSE DATEADD(MINUTE, (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], i.[N], 38)) AS binary(4)) AS int) & 2147483647) % 600, DATEADD(DAY, 1 + (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', p.[N], 39)) AS binary(4)) AS int) & 2147483647) % 5 + (i.[N] - 1) * 30, p.[CreatedDateTime])) END AS [TransactionDateTime]
    ) AS x
    WHERE p.[TotalPremium] > 0;

    INSERT INTO [Transaction].[PolicyPayments]
        ([PolicyId], [PolicyTypeId], [Amount], [TransactionDateTime], [TransactionCheckNo], [TransactionOrigin], [NotificationDateTime], [PaymentMethod], [Notes],
         [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
    SELECT
        np.[PolicyId], np.[PolicyTypeId], np.[Amount], np.[TransactionDateTime],
        CONCAT(CASE WHEN (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', np.[N], np.[Instalment], 40)) AS binary(4)) AS int) & 2147483647) % 3 = 0 THEN N'CHK' ELSE N'TRX' END, RIGHT(CONCAT(N'0000000', np.[N] * 10 + np.[Instalment]), 7)),
        CASE (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', np.[N], np.[Instalment], 41)) AS binary(4)) AS int) & 2147483647) % 6 WHEN 0 THEN N'Online' WHEN 1 THEN N'Branch' WHEN 2 THEN N'Bank Deposit' WHEN 3 THEN N'GCash' WHEN 4 THEN N'Over the Counter' ELSE N'Partner Remittance' END,
        np.[NotificationDateTime],
        27 + (CAST(CAST(HASHBYTES('MD5', CONCAT_WS(':', np.[N], np.[Instalment], 42)) AS binary(4)) AS int) & 2147483647) % 7,
        np.[Notes],
        @UserId, np.[TransactionDateTime], @UserId, np.[TransactionDateTime]
    FROM #NewPayments AS np
    ORDER BY np.[TransactionDateTime], np.[N], np.[Instalment];

    /* Payment status from totals; bookings whose COC was cancelled are marked Cancelled. */
    UPDATE t
    SET [PaymentStatusId] = CASE WHEN t.[CocStatusId] = 4 THEN 4 ELSE [Transaction].[GetPaymentStatusId](tot.[TotalPremium], tot.[TotalPaid]) END
    FROM [Transaction].[IndividualPolicy] AS t
    INNER JOIN #P AS p ON p.[PolicyTypeId] = 1 AND p.[PolicyId] = t.[Id]
    CROSS APPLY [Transaction].[GetPolicyTotals](1, t.[Id]) AS tot;

    UPDATE t
    SET [PaymentStatusId] = CASE WHEN t.[CocStatusId] = 4 THEN 4 ELSE [Transaction].[GetPaymentStatusId](tot.[TotalPremium], tot.[TotalPaid]) END
    FROM [Transaction].[PartnerPolicy] AS t
    INNER JOIN #P AS p ON p.[PolicyTypeId] = 2 AND p.[PolicyId] = t.[Id]
    CROSS APPLY [Transaction].[GetPolicyTotals](2, t.[Id]) AS tot;

    UPDATE t
    SET [PaymentStatusId] = CASE WHEN t.[CocStatusId] = 4 THEN 4 ELSE [Transaction].[GetPaymentStatusId](tot.[TotalPremium], tot.[TotalPaid]) END
    FROM [Transaction].[GroupPolicy] AS t
    INNER JOIN #P AS p ON p.[PolicyTypeId] = 3 AND p.[PolicyId] = t.[Id]
    CROSS APPLY [Transaction].[GetPolicyTotals](3, t.[Id]) AS tot;

    /* Attachments: policy documents for half of the bookings (group bookings also get the member declaration) and proof of payment for a third of payments. */
    INSERT INTO [Transaction].[Attachments]
        ([ReferenceId], [AttachmentTypeId], [ContentType], [FileName], [Attachment], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
    SELECT
        p.[PolicyId], d.[AttachmentTypeId], N'text/csv',
        CONCAT(p.[ReferenceNumber], d.[Suffix]),
        CAST(CAST(CONCAT('ReferenceNumber,CocNumber,Document,UploadedUtc', CHAR(13), CHAR(10),
                         CAST(p.[ReferenceNumber] AS varchar(12)), ',', CAST(p.[CocNumber] AS varchar(12)), ',', d.[Document], ',',
                         CONVERT(varchar(33), p.[CreatedDateTime], 126)) AS varchar(max)) AS varbinary(max)),
        @UserId, p.[CreatedDateTime], @UserId, p.[CreatedDateTime]
    FROM #P AS p
    INNER JOIN (VALUES
        (1, 1, '_policy_documents.csv', 'Individual policy documents'),
        (2, 2, '_policy_documents.csv', 'Partner policy documents'),
        (3, 3, '_group_policy_copy.csv', 'Group policy copy'),
        (3, 4, '_group_declaration.csv', 'Group declaration file')
    ) AS d ([PolicyTypeId], [AttachmentTypeId], [Suffix], [Document]) ON d.[PolicyTypeId] = p.[PolicyTypeId]
    WHERE p.[N] % 2 = 0
    ORDER BY p.[CreatedDateTime], p.[N], d.[AttachmentTypeId];

    INSERT INTO [Transaction].[Attachments]
        ([ReferenceId], [AttachmentTypeId], [ContentType], [FileName], [Attachment], [CreatedBy], [CreatedDateTime], [ModifiedBy], [ModifiedDateTime])
    SELECT
        pay.[Id], 5, N'text/csv',
        CONCAT(p.[ReferenceNumber], N'_proof_of_payment_', pay.[Id], N'.csv'),
        CAST(CAST(CONCAT('ReferenceNumber,TransactionCheckNo,Amount,TransactionUtc', CHAR(13), CHAR(10),
                         CAST(p.[ReferenceNumber] AS varchar(12)), ',', CAST(pay.[TransactionCheckNo] AS varchar(50)), ',',
                         CAST(pay.[Amount] AS varchar(30)), ',', CONVERT(varchar(33), pay.[TransactionDateTime], 126)) AS varchar(max)) AS varbinary(max)),
        @UserId, pay.[TransactionDateTime], @UserId, pay.[TransactionDateTime]
    FROM #P AS p
    INNER JOIN [Transaction].[PolicyPayments] AS pay ON pay.[PolicyTypeId] = p.[PolicyTypeId] AND pay.[PolicyId] = p.[PolicyId]
    WHERE pay.[Id] % 3 = 0
    ORDER BY pay.[Id];

    DROP TABLE IF EXISTS #NewPayments;
    DROP TABLE IF EXISTS #P;
    DROP TABLE IF EXISTS #ProductPool;
    DROP TABLE IF EXISTS #Pool;
END;
GO

DROP TABLE IF EXISTS #People;
DROP TABLE IF EXISTS #Towns;
DROP TABLE IF EXISTS #Streets;
DROP TABLE IF EXISTS #LastNames;
DROP TABLE IF EXISTS #FirstNames;
DROP TABLE IF EXISTS #Numbers;
GO

/* ---------- Move the number sequences past every seeded reference and COC number ---------- */

DECLARE @Next bigint, @Current bigint, @Sql nvarchar(400);

SELECT @Next = ISNULL(MAX(TRY_CAST(RIGHT([ReferenceNumber], 9) AS bigint)), 0) + 1 FROM [Transaction].[IndividualPolicy];
SELECT @Current = CAST([current_value] AS bigint) FROM sys.sequences WHERE [object_id] = OBJECT_ID(N'[Transaction].[IndividualPolicyNumberSequence]');
IF @Next > @Current
BEGIN
    SET @Sql = N'ALTER SEQUENCE [Transaction].[IndividualPolicyNumberSequence] RESTART WITH ' + CAST(@Next AS nvarchar(20)) + N';';
    EXEC sys.sp_executesql @Sql;
END;

SELECT @Next = ISNULL(MAX(TRY_CAST(RIGHT([ReferenceNumber], 9) AS bigint)), 0) + 1 FROM [Transaction].[PartnerPolicy];
SELECT @Current = CAST([current_value] AS bigint) FROM sys.sequences WHERE [object_id] = OBJECT_ID(N'[Transaction].[PartnerPolicyNumberSequence]');
IF @Next > @Current
BEGIN
    SET @Sql = N'ALTER SEQUENCE [Transaction].[PartnerPolicyNumberSequence] RESTART WITH ' + CAST(@Next AS nvarchar(20)) + N';';
    EXEC sys.sp_executesql @Sql;
END;

SELECT @Next = ISNULL(MAX(TRY_CAST(RIGHT([ReferenceNumber], 9) AS bigint)), 0) + 1 FROM [Transaction].[GroupPolicy];
SELECT @Current = CAST([current_value] AS bigint) FROM sys.sequences WHERE [object_id] = OBJECT_ID(N'[Transaction].[GroupPolicyNumberSequence]');
IF @Next > @Current
BEGIN
    SET @Sql = N'ALTER SEQUENCE [Transaction].[GroupPolicyNumberSequence] RESTART WITH ' + CAST(@Next AS nvarchar(20)) + N';';
    EXEC sys.sp_executesql @Sql;
END;

SELECT @Next = ISNULL(MAX(x.[Coc]), 0) + 1
FROM (SELECT TRY_CAST([CocNumber] AS bigint) AS [Coc] FROM [Transaction].[IndividualPolicy]
      UNION ALL SELECT TRY_CAST([CocNumber] AS bigint) FROM [Transaction].[PartnerPolicy]
      UNION ALL SELECT TRY_CAST([CocNumber] AS bigint) FROM [Transaction].[GroupPolicy]) AS x;
SELECT @Current = CAST([current_value] AS bigint) FROM sys.sequences WHERE [object_id] = OBJECT_ID(N'[Transaction].[CocNumberSequence]');
IF @Next > @Current
BEGIN
    SET @Sql = N'ALTER SEQUENCE [Transaction].[CocNumberSequence] RESTART WITH ' + CAST(@Next AS nvarchar(20)) + N';';
    EXEC sys.sp_executesql @Sql;
END;
GO
