defmodule CihReportPlugs.Repo.Migrations.CreatePlugs do
  use Ecto.Migration
  @moduledoc """
  This migration creates the plugs table within the CIH database

  In order for this to correctly interact with the database six triggers and one stored procedure are used.
  The six triggers just call the stored procedure with different arguments.

  On the dashboard table and the ocb table add these three triggers:
  For dashboard keep them like this. For ocb change the 0 to a 1 and 2 to a 3 in the call to the stored procedure.

  update_cih:
      CREATE DEFINER=`root`@`%` TRIGGER update_cih
      BEFORE UPDATE
      ON plugs FOR EACH ROW
      BEGIN
				if new.update_flag <> 1 then
					call bnw_dashboard_cih_report_plugs_dev.update_cih(
						new.id,
						new.projected_out_weight,
						new.max_out_weight,
						new.railer_be,
						new.projected_be,
						new.projected_ship_days,
						new.created_at,
						new.b_freight,
						new.n_freight,
						new.q_freight,
						new.b_bic,
						new.n_bic,
						new.q_bic,
						new.b_feed,
						new.n_feed,
						new.q_feed,
						new.tsp_days,
						new.recalc_be_days,
						new.recalc_feed_days,
						0
					);
	      end if;
	      set new.update_flag = 0;
      END

  insert_cih:
      CREATE DEFINER=`root`@`%` TRIGGER update_cih
      BEFORE INSERT
      ON plugs FOR EACH ROW
      BEGIN
	      if new.update_flag <> 1 then
					call bnw_dashboard_cih_report_plugs_dev.update_cih(
						new.id,
						new.projected_out_weight,
						new.max_out_weight,
						new.railer_be,
						new.projected_be,
						new.projected_ship_days,
						new.created_at,
						new.b_freight,
						new.n_freight,
						new.q_freight,
						new.b_bic,
						new.n_bic,
						new.q_bic,
						new.b_feed,
						new.n_feed,
						new.q_feed,
						new.tsp_days,
						new.recalc_be_days,
						new.recalc_feed_days,
						0
					);
	      end if;
	      set new.update_flag = 0;
      END

  and delete_cih:
      CREATE DEFINER=`root`@`%` TRIGGER delete_cih
      BEFORE DELETE
      ON plugs FOR EACH ROW
      BEGIN
	      if new.update_flag <> 1 then
					call bnw_dashboard_cih_report_plugs_dev.update_cih(
						new.id,
						new.projected_out_weight,
						new.max_out_weight,
						new.railer_be,
						new.projected_be,
						new.projected_ship_days,
						new.created_at,
						new.b_freight,
						new.n_freight,
						new.q_freight,
						new.b_bic,
						new.n_bic,
						new.q_bic,
						new.b_feed,
						new.n_feed,
						new.q_feed,
						new.tsp_days,
						new.recalc_be_days,
						new.recalc_feed_days,
						2
					);
	      end if;
      END


  lastly create the stored procedure:
      CREATE PROCEDURE bnw_dashboard_cih_report_plugs_dev.update_cih(	l_id bigint(20),
                                                                      l_projected_out_weight int(11),
                                                                      l_max_out_weight int(11),
                                                                      l_railer_be decimal(12,0),
                                                                      l_projected_be decimal(12,0),
                                                                      l_projected_ship_days int(11),
                                                                      l_created_at timestamp,
                                                                      l_b_freight decimal(12,0),
                                                                      l_n_freight decimal(12,0),
                                                                      l_q_freight decimal(12,0),
                                                                      l_b_bic decimal(12,0),
                                                                      l_n_bic decimal(12,0),
                                                                      l_q_bic decimal(12,0),
                                                                      l_b_feed decimal(12,0),
                                                                      l_n_feed decimal(12,0),
                                                                      l_q_feed decimal(12,0),
                                                                      l_tsp_days int(11),
                                                                      l_recalc_be_days int(11),
                                                                      l_recalc_feed_days int(11),
                                                                      l_where int(1))
      BEGIN
        if l_where = 0 then
          if l_id in (select id from cih.plugs) then
            update cih.plugs
              set	projected_out_weight = l_projected_out_weight,
                  max_out_weight       = l_max_out_weight,
                  railer_be            = l_railer_be,
                  projected_be         = l_projected_be,
                  projected_ship_days  = l_projected_ship_days,
                  created_at           = l_created_at,
                  b_freight            = l_b_freight,
                  n_freight            = l_n_freight,
                  q_freight            = l_q_freight,
                  b_bic                = l_b_bic,
                  n_bic                = l_n_bic,
                  q_bic                = l_q_bic,
                  b_feed               = l_b_feed,
                  n_feed               = l_n_feed,
                  q_feed               = l_q_feed,
                  tsp_days             = l_tsp_days,
                  recalc_be_days       = l_recalc_be_days,
                  recalc_feed_days     = l_recalc_feed_days,
                  update_flag          = 1
                where id = l_id;
          else
            insert into cih.plugs (	id,
                                    projected_out_weight,
                                    max_out_weight,
                                    railer_be,
                                    projected_be,
                                    projected_ship_days,
                                    created_at,
                                    b_freight,
                                    n_freight,
                                    q_freight,
                                    b_bic,
                                    n_bic,
                                    q_bic,
                                    b_feed,
                                    n_feed,
                                    q_feed,
                                    tsp_days,
                                    recalc_be_days,
                                    recalc_feed_days,
                                    update.update_flag)
            values (l_id,
                    l_projected_out_weight,
                    l_max_out_weight,
                    l_railer_be,
                    l_projected_be,
                    l_projected_ship_days,
                    l_created_at,
                    l_b_freight,
                    l_n_freight,
                    l_q_freight,
                    l_b_bic,
                    l_n_bic,
                    l_q_bic,
                    l_b_feed,
                    l_n_feed,
                    l_q_feed,
                    l_tsp_days,
                    l_recalc_be_days,
                    l_recalc_feed_days,
                    1
                  );
          end if;
        elseif l_where = 1 then
          if l_id in (select id from cih.plugs) then
            update ocb.plugs
              set	projected_out_weight = l_projected_out_weight,
                  max_out_weight       = l_max_out_weight,
                  railer_be            = l_railer_be,
                  projected_be         = l_projected_be,
                  projected_ship_days  = l_projected_ship_days,
                  created_at           = l_created_at,
                  b_freight            = l_b_freight,
                  n_freight            = l_n_freight,
                  q_freight            = l_q_freight,
                  b_bic                = l_b_bic,
                  n_bic                = l_n_bic,
                  q_bic                = l_q_bic,
                  b_feed               = l_b_feed,
                  n_feed               = l_n_feed,
                  q_feed               = l_q_feed,
                  tsp_days             = l_tsp_days,
                  recalc_be_days       = l_recalc_be_days,
                  recalc_feed_days     = l_recalc_feed_days,
                  update_flag          = 1
                where id = l_id;
          else
            insert into cih.plugs (	id,
                                    projected_out_weight,
                                    max_out_weight,
                                    railer_be,
                                    projected_be,
                                    projected_ship_days,
                                    created_at,
                                    b_freight,
                                    n_freight,
                                    q_freight,
                                    b_bic,
                                    n_bic,
                                    q_bic,
                                    b_feed,
                                    n_feed,
                                    q_feed,
                                    tsp_days,
                                    recalc_be_days,
                                    recalc_feed_days,
                                    update.update_flag)
            values (l_id,
                    l_projected_out_weight,
                    l_max_out_weight,
                    l_railer_be,
                    l_projected_be,
                    l_projected_ship_days,
                    l_created_at,
                    l_b_freight,
                    l_n_freight,
                    l_q_freight,
                    l_b_bic,
                    l_n_bic,
                    l_q_bic,
                    l_b_feed,
                    l_n_feed,
                    l_q_feed,
                    l_tsp_days,
                    l_recalc_be_days,
                    l_recalc_feed_days,
                    1
                  );
          end if;
				elseif l_where = 2 then
					update cih.plugs
  					set id = 0,
  					update_flag = 1
  					where id = l_id;
    			delete from cih.plugs
    				where id = 0;
        else
					update bnw_dashboard_cih_report_plugs_dev.plugs
  					set id = 0,
  					update_flag = 1
  					where id = l_id;
    			delete from bnw_dashboard_cih_report_plugs_dev.plugs
    				where id = 0;
        end if;
      END
  """

  @doc """
  This function creates the table in the database
  """
  def change do
    create table(:plugs) do
      add :projected_out_weight, :integer, default: 0, null: 0
      add :max_out_weight, :integer, default: 0, null: 0
      add :railer_be, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :projected_be, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :projected_ship_days, :integer, default: 0, null: 0
      add :created_at, :timestamp
      add :b_freight, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :n_freight, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :q_freight, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :b_bic, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :n_bic, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :q_bic, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :b_feed, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :n_feed, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :q_feed, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :tsp_days, :integer, default: 0, null: 0
      add :recalc_be_days, :integer, default: 0, null: 0
      add :recalc_feed_days, :integer, default: 0, null: 0
      add :update_flag, :integer, default: 0, null: 0
    end
  end
end
