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
	--DECLARE @fd_beginTime varchar(100),@fd_endTime varchar(100)
	create table #tongjifeiyong(
		forgid varchar(200),
		ftype varchar(100),
		fmount decimal(18,2),
	)
	insert #tongjifeiyong
	select t1.fd_chengdanbumen,t1.fd_3651029d66ed78_text,SUM(t1.fd_fukuanjine) as fd_jinE from ekp_yufukuan t1
	where 1=1
		AND 1 = CASE WHEN ISNULL(@fd_beginTime, '') = ''  THEN 1
		ELSE CASE WHEN t1.fd_shenqingriqi>=@fd_beginTime 
				THEN 1
				ELSE 0
			END
		END
		AND 1 = CASE WHEN ISNULL(@fd_endTime, '') = ''  THEN 1
		ELSE CASE WHEN t1.fd_shenqingriqi<=@fd_endTime 
				THEN 1
				ELSE 0
			END
		END
