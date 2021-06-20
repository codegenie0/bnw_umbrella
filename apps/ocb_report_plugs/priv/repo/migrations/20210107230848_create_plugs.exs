defmodule OcbReportPlugs.Repo.Migrations.CreatePlugs do
  use Ecto.Migration
  @moduledoc """
  This migration creates the plugs table within the OCB database

  In order for this to correctly interact with the database six triggers and one stored procedure are used.
  The six triggers just call the stored procedure with different arguments.

  On the dashboard table and the ocb table add these three triggers:
  For dashboard keep them like this. For ocb change the 0 to a 1 and 2 to a 3 in the call to the stored procedure.

  update_ocb:
      CREATE DEFINER=`root`@`%` TRIGGER update_ocb
      BEFORE UPDATE
      ON plugs FOR EACH ROW
      BEGIN
	      if new.update_flag <> 1 then
      		call bnw_dashboard_ocb_report_plugs_dev.update_ocb(
			      new.id,
			      new.carcass_low,
			      new.carcass_high,
			      new.calculated_yield_grade,
			      new.quality_grade,
			      new.add_30,
			      new.add_ag,
			      0
		      );
	      end if;
	      set new.update_flag = 0;
      END

  insert_ocb:
      CREATE DEFINER=`root`@`%` TRIGGER update_ocb
      BEFORE INSERT
      ON plugs FOR EACH ROW
      BEGIN
	      if new.update_flag <> 1 then
      		call bnw_dashboard_ocb_report_plugs_dev.update_ocb(
			      new.id,
			      new.carcass_low,
			      new.carcass_high,
			      new.calculated_yield_grade,
			      new.quality_grade,
			      new.add_30,
			      new.add_ag,
			      0
		      );
	      end if;
	      set new.update_flag = 0;
      END

  and delete_ocb:
      CREATE DEFINER=`root`@`%` TRIGGER delete_ocb
      BEFORE DELETE
      ON plugs FOR EACH ROW
      BEGIN
	      if old.update_flag <> 1 then
		      call bnw_dashboard_ocb_report_plugs_dev.update_ocb(
			      old.id,
			      old.carcass_low,
			      old.carcass_high,
			      old.calculated_yield_grade,
			      old.quality_grade,
			      old.add_30,
			      old.add_ag,
			      2
		      );
	      end if;
      END


  lastly create the stored procedure:
      CREATE PROCEDURE bnw_dashboard_ocb_report_plugs_dev.update_ocb(l_id bigint(20),
                                                                    l_carcass_low int(11),
                                                                    l_carcass_high int(11),
                                                                    l_calculated_yield_grade int(11),
                                                                    l_quality_grade varchar(255),
                                                                    l_add_30 int(11),
                                                                    l_add_ag int(11),
                                                                    l_where int(1))
      BEGIN
	      if l_where = 0 then
	      	if l_id in (select id from ocb.plugs) then
		      	update ocb.plugs
				      set carcass_low = l_carcass_low,
				      	carcass_high = l_carcass_high,
					      calculated_yield_grade = l_calculated_yield_grade,
					      quality_grade = l_quality_grade,
					      add_30 = l_add_30,
				      	add_ag = l_add_ag,
					      update_flag = 1
				      where id = l_id;
	      	else
			      insert into ocb.plugs (id, carcass_low, carcass_high, calculated_yield_grade, quality_grade, add_30, add_ag, update_flag)
			      values (l_id, l_carcass_low, l_carcass_high, l_calculated_yield_grade, l_quality_grade, l_add_30, l_add_ag, 1);
		      end if;
	      elseif l_where = 1 then
			      if l_id in (select id from bnw_dashboard_ocb_report_plugs_dev.plugs) then
			      update bnw_dashboard_ocb_report_plugs_dev.plugs
				      set carcass_low = l_carcass_low,
					      carcass_high = l_carcass_high,
					      calculated_yield_grade = l_calculated_yield_grade,
					      quality_grade = l_quality_grade,
					      add_30 = l_add_30,
					      add_ag = l_add_ag,
					      update_flag = 1
				      where id = l_id;
	      	else
			      insert into bnw_dashboard_ocb_report_plugs_dev.plugs (id, carcass_low, carcass_high, calculated_yield_grade, quality_grade, add_30, add_ag, update_flag)
			      values (l_id, l_carcass_low, l_carcass_high, l_calculated_yield_grade, l_quality_grade, l_add_30, l_add_ag, 1);
		      end if;
        elseif l_where = 2 then
          update ocb.plugs
  		      set id = 0,
  			        update_flag = 1
  		        where id = l_id;
          delete from ocb.plugs
            where id = 0;
	      else
          update bnw_dashboard_ocb_report_plugs_dev.plugs
  		      set id = 0,
  			        update_flag = 1
  		        where id = l_id;
          delete from bnw_dashboard_ocb_report_plugs_dev.plugs
            where id = 0;
	        end if;
      END
  """

  @doc """
  This function creates the table in the database
  """

  def change do
    create table(:plugs) do
      add :carcass_low, :integer, default: 0, null: 0
      add :carcass_high, :integer, default: 0, null: 0
      add :calculated_yield_grade, :decimal, default: 0.000, null: 0.000
      add :quality_grade, :string, null: ""
      add :add_30, :integer, default: 0, null: 0
      add :add_ag, :integer, default: 0, null: 0
      add :update_flag, :integer, default: 0, null: 0
    end
  end
end
