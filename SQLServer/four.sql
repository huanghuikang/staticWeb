USE [ekp]
GO
/****** Object:  StoredProcedure [dbo].[yufukuan_fukuan]    Script Date: 11/07/2018 11:27:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[yufukuan_fukuan]
	--(@fd_faShengKaiShiShiJian datetime,@fd_faShengJieShuShiJian datetime)
	(
		@fd_beginTime varchar(100) ,
		@fd_endTime varchar(100)
	)
AS
BEGIN
