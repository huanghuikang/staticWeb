USE [ekp]
GO
/****** Object:  StoredProcedure [dbo].[tongjiTFCLjianshu]    Script Date: 2018/11/14 14:46:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[tongjiTFCLjianshu]

AS
BEGIN

	SET NOCOUNT ON;
	--创建表用于对超时完成，超时末完成和按时完成统计
