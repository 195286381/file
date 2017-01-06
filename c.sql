DROP TABLE IF EXISTS Tmp_Erab_517_SetupFailureBase;
CREATE TABLE Tmp_Erab_517_SetupFailureBase
(
    IMSI varchar(80),
    ErabSetupTime bigint,
    CallType int,
    Qci int,
    SetupENB bigint,
    SetupCELLID int,
    PCI int,
    tCallId varchar(80),
    tSip varchar(80),
    tDip varchar(80),
    tForm varchar(80),
    tTo varchar(80),
    SetupRSRP numeric(10,2),
    SetupRSRQ numeric(10,2),
    SetupLon numeric(18,2),
    SetupLat numeric(18,2),
    SetupRegionID int,
    ReleaseX_Offset int,  
    ReleaseY_Offset int, 
    ErabSetupResult int,
    ErabSetupFailReason int,
	
	CauseClass varchar(100),
	CauseClassID int,
	CauseSubClass varchar(100),
	CauseSubClassID int,
	CauseDescription varchar(256),
	CauseDescriptionID int,
	
    MMEC int,
    MMEApID bigint,
    MMEGroupID int,
    GID int,
    CallRecordUEID varchar(512),
    AccessERFCN numeric(10,2),
    SetupCoverType int,
    CQI numeric(18,2)
);  --´´½¨Ò»ÕÅÁÙÊ±±í
DROP TABLE IF EXISTS Tmp_Erab_517_SetupJoinT167;
CREATE TABLE Tmp_Erab_517_SetupJoinT167
(
    D004 bigint,
    D005 int,
    D020 varchar(512),
    ulbler numeric(10,2),
    dlbler numeric(10,2),
); --´´½¨ÁíÍâÒ»ÕÅÁÙÊ±±í
COMMIT;



CREATE OR REPLACE PROCEDURE Sp_ExportData_CreatView_Erab_AccessFailure(IN v_begintime bigint, --´´½¨Ò»¸ö´æ´¢¹ý³Ì ´«Èë¿ªÊ¼Ê±¼ä ½áÊøÊ±¼ä ºÍ Õ¤¸ñ´óÐ¡
                                                                  IN v_endtime bigint,
                                                                  IN v_gridsize int)
BEGIN
    declare sSQL VARCHAR(32167); --ÉùÃ÷Ò»¸ösSQL×Ö·û´®
    declare dropSQL VARCHAR(32167); --ÉùÃ÷Ò»¸ödrop×Ö·û´®
    DECLARE xy_by_gridsize VARCHAR(2000); --ÉùÃ÷Ò»¸öxyÖá(Í¨¹ýÕ¤¸ñ´óÐ¡»ñÈ¡)×Ö·û´®
    
    SET sSQL = 'SELECT convert_xy_by_gridsize(''A.C072'',''A.C073'','||v_gridsize||',''SetupX_Offset'',''SetupY_Offset'') INTO xy_by_gridsize';
    EXECUTE IMMEDIATE sSQL;
    
    SET dropSQL = 'TRUNCATE Table Tmp_Erab_517_SetupFailureBase;
                  TRUNCATE TABLE Tmp_Erab_517_SetupJoinT167;
'; 
	CALL Sp_etl_log('Sp_ExportData_CreatView_Erab_AccessFailure', sSQL ,'1', '1'); --µ÷ÓÃÒ»¸ö´æ´¢¹ý³Ì
    EXECUTE IMMEDIATE dropSQL;
    --CALL Sp_GetExportPeroid_IMSI_InfoTab(v_begintime, v_endtime, 'ExportData_IMSI_RecordID_Info');

    SET sSQL = '
        INSERT INTO Tmp_Erab_517_SetupFailureBase
        SELECT D.D023 AS IMSI, A.D027 AS ErabSetupTime,
        1-E.direction AS CallType,
            A.C007 AS Qci, A.D004 AS SetupENB, A.D005 AS SetupCELLID,
            A.C004 AS PCI, E.tCallId, E.tSip, E.tDip, E.tForm, E.tTo,
            A.C011 AS SetupRSRP, A.C012 AS SetupRSRQ, A.C070 AS SetupLon,
            A.C071 AS SetupLat, A.C074 AS SetupRegionID, '||xy_by_gridsize||',
            CASE WHEN A.C054=0 THEN 0 
				 WHEN A.C054=-1 THEN NULL
                 ELSE 1 END AS ErabSetupResult,
            CauseSubClassID AS ErabSetupFailReason, 
			(case when a.C056 is not null then Tc.C009 else T3.C009 end) as CauseClass, 
			(case when a.C056 is not null then Tc.C010 else T3.C010 end) as CauseClassID, 
			(case when a.C056 is not null then Tc.C002 else T2.C003 end) as CauseSubClass, 
			(case when a.C056 is not null then Tc.C011 else T2.C007 end) as CauseSubClassID, 
			(case when a.C056 is not null then Tc.C007 else T2.C003 end) as CauseDescription,
			(case when a.C056 is not null then Tc.C012 else T2.C008 end) as CauseDescriptionID, 
			A.C001 AS MMEC, A.C002 AS MMEApID,
            A.C003 AS MMEGroupID, A.D026 AS GID, A.D020 AS CallRecordUEID,
            C.C054 as AccessERFCN, 
            CASE WHEN B.pos = CAST(C.pos AS INT) THEN 1-B.pos&CAST(C.pos AS INT) 
            ELSE 2-B.pos&CAST(C.pos AS INT) END AS SetupCoverType,B.CQI
        FROM
        V_T305 A
		left join T028_FailType Tc on a.C056 = Tc.C001 
		left join T028 T2 on T2.C001=1 AND a.C056 is null 
			and 2 = T2.C005 and a.C010 = T2.C002
		left join T028_FailType T3 on T2.C004=T3.C001
        LEFT JOIN 
        (
            SELECT D020, C030, C129 AS pos,
                   CASE WHEN C123 IS NULL OR C123<0 OR C123>15 THEN 0 ELSE C123 END AS CQI0,
                  CASE WHEN C124 IS NULL OR C124<0 OR C124>15 THEN 0 ELSE C124 END AS CQI1,
                 (CQI0 +CQI1)/2.0 AS CQI
            FROM T054
            WHERE C008>='||v_begintime||' AND C008<'||v_endtime||'
        )B 
            ON A.D020||A.C055=B.D020||B.C030 
        LEFT JOIN 
        (
            SELECT D004, D005, C054, C015 AS pos FROM T001
        )C
            ON A.D004=C.D004 and A.D005=C.D005
        LEFT JOIN ExportData_IMSI_RecordID_Info D 
            ON A.D020=D.D020 AND A.D027>=D.begintime AND A.D027<D.endtime
        LEFT JOIN 
        (
			SELECT A.D020,A.D023, tCallId, tSip, tDip, tForm, tTo, direction
			FROM
			(
				SELECT  A.D020,A.D023, ABS(A.D027-B.D027) AS datediff, tCallId, tSip, tDip, tForm, tTo, direction,
				ROW_NUMBER() OVER(partition by A.D020, A.D023 order by  datediff asc) AS RN
				FROM 
				(
					SELECT DISTINCT D020, D023, D027
					FROM V_T305 
					WHERE D027>='||v_begintime||' AND D027<'||v_endtime||' AND C054=1 AND C007 IN(1,2,5)
				)A
				LEFT JOIN 
				(
					SELECT D020, D023, D027, C005 AS tCallId, C008 AS tSip,
						C009 AS tDip, C010 AS tForm, C011 AS tTo, C006 AS direction 
					FROM T307 
					WHERE (case when D027-C003>-946684800+7*3600 then C003-946684800+8*3600 else C003-946684800 end)>= '||v_begintime||' 
						and (case when D027-C003>-946684800+7*3600 then C003-946684800+8*3600 else C003-946684800 end) < '||v_endtime||' AND C007=0
				)B
				ON A.D020||A.D023 =B.D020||B.D023
			)A
			WHERE RN =1
        )E
        ON A.D020||A.D023=D.D020||D.D023
        WHERE A.D027>='||v_begintime||' AND A.D027<'||v_endtime||' AND A.C054=1 AND A.C007 IN(1,2)';
	CALL Sp_etl_log('Sp_ExportData_CreatView_Erab_AccessFailure', sSQL ,'2', '2');
    EXECUTE IMMEDIATE sSQL;
    
    SET sSQL = 
        'INSERT INTO  Tmp_Erab_517_SetupJoinT167
        SELECT D004,D005,D020, ulbler, dlbler FROM
        (
            SELECT A.D004, A.D005, A.D020, A.D027,
                CASE WHEN PuschAckCnt IS NULL OR PuschNackCnt IS NULL THEN NULL
                    WHEN PuschAckCnt+PuschNackCnt=0 THEN NULL
                ELSE
                    1.0*PuschAckCnt/(PuschAckCnt+PuschNackCnt) END AS ulbler,
                    
                CASE WHEN PdschAckCnt IS NULL OR PdschDtxCnt IS NULL OR PdschNackCnt IS NULL THEN NULL
                    WHEN PdschAckCnt+PdschDtxCnt+PdschNackCnt=0 THEN NULL
                ELSE
                    1.0*(PdschDtxCnt+PdschNackCnt)/(PdschAckCnt+PdschDtxCnt+PdschNackCnt) END AS dlbler,
                ABS(A.D027-B.D027) AS datedif,
                ROW_NUMBER() OVER(partition by A.D020, A.D004, A.D005, A.D027 order by  datedif asc) as RN
    
            FROM 
            (
                SELECT SetupENB AS D004, SetupCELLID AS D005, CallRecordUEID AS D020, ErabSetupTime as D027 from Tmp_Erab_517_SetupFailureBase
            )A
            INNER JOIN
            (
                SELECT D004,D005,D020,D027,
                    CASE WHEN c001>c002 THEN c001 ELSE c002 END AS PuschAckCnt1,
                    CASE WHEN PuschAckCnt1>c003 THEN PuschAckCnt1 ELSE c003 END AS PuschAckCnt2,
                    CASE WHEN PuschAckCnt2>c004 THEN PuschAckCnt2 ELSE c004 END AS PuschAckCnt3,
                    CASE WHEN PuschAckCnt3>c005 THEN PuschAckCnt3 ELSE c005 END AS PuschAckCnt,
                    CASE WHEN c011>c012 THEN c011 ELSE c012 END AS PuschNackCnt1,
                    CASE WHEN PuschNackCnt1>c013 THEN PuschNackCnt1 ELSE c013 END AS PuschNackCnt2,
                    CASE WHEN PuschNackCnt2>c014 THEN PuschNackCnt2 ELSE c014 END AS PuschNackCnt3,
                    CASE WHEN PuschNackCnt3>c015 THEN PuschNackCnt3 ELSE c015 END AS PuschNackCnt,
                    CASE WHEN c006>c007 THEN c006 ELSE c007 END AS PdschAckCnt1,
                    CASE WHEN PdschAckCnt1>c008 THEN PdschAckCnt1 ELSE c008 END AS PdschAckCnt2,
                    CASE WHEN PdschAckCnt2>c009 THEN PdschAckCnt2 ELSE c009 END AS PdschAckCnt3,
                    CASE WHEN PdschAckCnt3>c010 THEN PdschAckCnt3 ELSE c010 END AS PdschAckCnt,
                    CASE WHEN c021>c022 THEN c021 ELSE c022 END AS PdschDtxCnt1,
                    CASE WHEN PdschDtxCnt1>c023 THEN PdschDtxCnt1 ELSE c023 END AS PdschDtxCnt2,
                    CASE WHEN PdschDtxCnt2>c024 THEN PdschDtxCnt2 ELSE c024 END AS PdschDtxCnt3,
                    CASE WHEN PdschDtxCnt3>c025 THEN PdschDtxCnt3 ELSE c025 END AS PdschDtxCnt,
                    CASE WHEN c016>c017 THEN c016 ELSE c017 END AS PdschNackCnt1,
                    CASE WHEN PdschNackCnt1>c018 THEN PdschNackCnt1 ELSE c018 END AS PdschNackCnt2,
                    CASE WHEN PdschNackCnt2>c019 THEN PdschNackCnt2 ELSE c019 END AS PdschNackCnt3,
                    CASE WHEN PdschNackCnt3>c020 THEN PdschNackCnt3 ELSE c020 END AS PdschNackCnt
                FROM T167 
                WHERE D027>='||v_begintime||' AND D027<'||v_endtime||'
            )B  
                ON A.D004||A.D005||A.D020=B.D004||B.D005||B.D020
        )C
        WHERE RN =1
        ';
	CALL Sp_etl_log('Sp_ExportData_CreatView_Erab_AccessFailure', sSQL ,'3', '3'); --µ÷ÓÃ´æ´¢¹ý³Ì
    EXECUTE IMMEDIATE sSQL;
    
    SET sSQL = 
        'CREATE OR REPLACE VIEW V_VOLTE_SetupFailure AS SELECT NULL;
        CREATE OR REPLACE VIEW V_VOLTE_SetupFailure AS
        SELECT A.CallRecordUEID AS tID, A.IMSI, dateadd(second,A.ErabSetupTime,''2000-01-01'') AS ErabSetupTime,
            A.CallType, A.Qci, A.SetupENB, A.SetupCELLID, A.PCI, A.tCallId, A.tSip, A.tDip, A.tForm,
            A.tTo, A.SetupRSRP, A.SetupRSRQ, A.SetupLon, A.SetupLat, A.SetupRegionID, A.ReleaseX_Offset,
            A.ReleaseY_Offset, A.ErabSetupResult, A.ErabSetupFailReason, A.CauseClass AS CauseClass,
            A.CauseClassID AS CauseClassID, A.CauseSubClass AS CauseSubClass, A.CauseSubClassID AS CauseSubClassID, A.CauseDescription AS CauseDescription, 
            A.CauseDescriptionID AS CauseDescriptionID, A.MMEC, A.MMEApID, A.MMEGroupID, A.GID, A.CallRecordUEID, A.AccessERFCN,
            C.ulsinr, A.CQI AS CQI, B.ulbler, B.dlbler, A.SetupCoverType    
        FROM
        Tmp_Erab_517_SetupFailureBase A
        LEFT JOIN Tmp_Erab_517_SetupJoinT167 B
        ON  A.CallRecordUEID ||A.SetupENB||A.SetupCELLID=B.D020||B.D004||B.D005
        LEFT JOIN 
        (
            SELECT D004,D005,D020,D027, ulsinr 
            FROM
            (
                SELECT A.D004, A.D005, A.D020, A.D027, B.ulsinr,
                    ABS(A.D027-B.D027) AS datedif,
                    ROW_NUMBER() OVER(partition by A.D020, A.D004, A.D005, A.D027 order by  datedif asc) as RN
                FROM 
                (
                    SELECT SetupENB AS D004, SetupCELLID AS D005, CallRecordUEID AS D020, ErabSetupTime AS D027 
                    FROM Tmp_Erab_517_SetupFailureBase
                )A
                INNER JOIN
                (
                    SELECT D004, D005, D020, D027, C019 AS ulsinr
                    FROM T168
                    WHERE D027>='||v_begintime||' AND D027<'||v_endtime||'
                )B  
                    ON A.D004||A.D005||A.D020=B.D004||B.D005||B.D020
            )C
            WHERE RN =1
        )C
        ON A.CallRecordUEID ||A.SetupENB||A.SetupCELLID||A.ErabSetupTime=C.D020||C.D004||C.D005||C.D027';
	CALL Sp_etl_log('Sp_ExportData_CreatView_Erab_AccessFailure', sSQL ,'4', '4'); --µ÷ÓÃ´æ´¢¹ý³Ì
	
    EXECUTE IMMEDIATE sSQL;
    EXCEPTION
    WHEN OTHERS THEN
    CALL Sp_etl_log('Sp_ExportData_CreatView_Erab_AccessFailure', sSQL ,SQLCODE, errormsg(SQLCODE));
    ROLLBACK;
    RESIGNAL;
END;
commit;
