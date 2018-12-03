USE [ekp]
GO
/****** Object:  StoredProcedure [dbo].[bumenchaxunjiane]    Script Date: 11/07/2018 11:25:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[bumenchaxunjiane]
	@fd_beginTime varchar(100) ,
	@fd_endTime varchar(100),
	@fdept varchar(255)
AS
BEGIN
	create table #bumenchaxunjiane
	(
	
	fgroupid int,
	fd_type1 varchar(255),
	fd_type2 varchar(255),
	fd_jinE decimal(18,2)
	)
	insert #bumenchaxunjiane
	select 0,t2.fd_type1,t1.fd_365662c47e4e56_text,sum(isnull(t1.fd_jinE,0)) from ekp_baoxiaomingxi t1
	inner join
	ekp_gerenbaoxiao  t2 on t2.fd_id=t1.fd_parent_id
	inner join
	ekporg_feiyongPost t3 on t3.fd_parent_id=t2.fd_id
	inner join
	sys_org_element t4 on t4.fd_org_type=2 and t4.fd_id=t2.fd_jingBanBuMen
		where 1=1
	AND 1 = CASE WHEN ISNULL(@fdept, '') = '' THEN 1
        ELSE CASE WHEN ISNULL(t4.fd_name, '') = @fdept
            THEN 1
            ELSE 0
        END
    END
	AND 1 = CASE WHEN ISNULL(@fd_beginTime, '') = '' THEN 1
		ELSE CASE WHEN t2.fd_baoXiaoRiQi>=@fd_beginTime
		THEN 1
		ELSE 0
	END
    END
	AND 1 = CASE WHEN ISNULL(@fd_endTime, '') = '' THEN 1
	ELSE CASE WHEN t2.fd_baoXiaoRiQi<=@fd_endTime
			THEN 1
			ELSE 0
		END
    END
	group by t1.fd_365662c47e4e56_text,t2.fd_type1


	insert #bumenchaxunjiane
	select 1,fd_type1,'合计',sum(isnull(cast(fd_jinE as decimal(18,2)),0)) as '金额' from #bumenchaxunjiane group by fd_type1

	select DENSE_RANK() over(order by a.fd_type1) as '序号',a.fd_type1 as '一级类别',a.fd_type2 as '二级类别',a.fd_jinE as '金额' from #bumenchaxunjiane a  
	--order by fd_type1,fd_jinE desc
	order by fd_type1,fgroupid


	drop table #bumenchaxunjiane
END
