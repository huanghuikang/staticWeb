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
	group by t1.fd_chengdanbumen,t1.fd_3651029d66ed78_text
	insert #tongjifeiyong
	select t1.fd_chengdanbumen,t1.fd_3651029d66ed78_text,SUM(t1.fd_fukuanjine) as fd_jinE from ekp_fukuan2 t1
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
	group by t1.fd_chengdanbumen,t1.fd_3651029d66ed78_text
	--行转列的实现
	DECLARE @sql VARCHAR(8000),@sqlname VARCHAR(8000)
	select  @sqlname=isnull(@sqlname+',','')+ftype from #tongjifeiyong where isnull(ftype,'')<>'' group by ftype
	--select @sqlname
	SET @sql='SELECT cast(0 as decimal(18,2)) as fmounthz,* into tongjifeiyongs FROM #tongjifeiyong AS P PIVOT (  SUM(fmount) FOR  p.ftype IN ('+@sqlname+'   ) ) AS T'
	exec(@sql)
	select forgid,sum(fmount) as fmounthz  into #tongjifeiyonghz from #tongjifeiyong group by forgid
	if  exists(select 1 from sys.objects  where name='tongjifeiyongs')
	begin
		update t1 set fmounthz=t2.fmounthz from tongjifeiyongs t1
		inner join
		#tongjifeiyonghz t2 on t2.forgid=t1.forgid
	end
	begin
		create table #elementFen
		(
			fd_id varchar(100),
			diselement varchar(200),
			fd_name varchar(180)
		)
		insert #elementFen
		select t1.fd_id,t2.fd_name,t1.fd_name from sys_org_element t1
		inner join
		(
		select fd_id,fd_name from sys_org_element where  fd_org_type=1
		) t2 on t1.fd_parentorgid=t2.fd_id
		where t1.fd_org_type=2
	end
	declare @sqlstr varchar(8000)
	set @sqlstr='select RANK() OVER(ORDER BY t2.fd_name) AS 序号,t2.diselement as '+'公司,t2.fd_name as '+  '部门名称,t1.fmounthz as 汇总金额,' + @sqlname +  ' from tongjifeiyongs t1 inner join  #elementFen t2 on t2.fd_id=t1.forgid '
	exec(@sqlstr)
	drop table #tongjifeiyonghz
	drop table #tongjifeiyong
	if  exists(select 1 from sys.objects  where name='tongjifeiyongs')
	begin
		drop table #elementFen
		drop table tongjifeiyongs
	end
end
