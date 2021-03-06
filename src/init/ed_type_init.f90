!==========================================================================================!
!==========================================================================================!
!     This subroutine assigns an initial value of zero for most cohort-level variables.    !
! There will be a few variables that must be initialised with a value other than zero, in  !
! which case there will be a note explaining the reason.                                   !
!------------------------------------------------------------------------------------------!
subroutine init_ed_cohort_vars(cpatch,ico, lsl)
   use ed_state_vars , only : patchtype           ! ! structure
   use allometry     , only : dbh2krdepth         ! ! function
   use pft_coms      , only : leaf_turnover_rate  & ! intent(in)
                            , Vm0                 & ! intent(in)
                            , sla                 ! ! intent(in)
   use ed_misc_coms  , only : imoutput            & ! intent(in)
                            , idoutput            & ! intent(in)
                            , iqoutput            ! ! intent(in)
   use phenology_coms, only : vm_tran             & ! intent(in)
                            , vm_slop             & ! intent(in)
                            , vm_amp              & ! intent(in)
                            , vm_min              ! ! intent(in)
   use cohort_state, only: init_cohort_vars_state
   use cohort_phen, only: init_cohort_vars_phen
   use cohort_mort, only: init_cohort_vars_mort
   use cohort_resp, only: init_cohort_vars_resp
   use cohort_photo, only: init_cohort_vars_photo
   use cohort_rad, only: init_cohort_vars_rad
   use cohort_therm, only: init_cohort_vars_therm

   implicit none

   !----- Arguments. ----------------------------------------------------------------------!
   type(patchtype), target     :: cpatch     ! Current patch
   integer        , intent(in) :: ico        ! Index of the current cohort
   integer        , intent(in) :: lsl        ! Lowest soil level layer
   !---------------------------------------------------------------------------------------!

   call init_cohort_vars_state(cpatch%costate, ico, lsl)
   call init_cohort_vars_phen(cpatch%cophen, ico, cpatch%costate%pft(ico))
   call init_cohort_vars_mort(cpatch%comort, ico)
   call init_cohort_vars_resp(cpatch%coresp, ico)
   call init_cohort_vars_photo(cpatch%cophoto, ico)
   call init_cohort_vars_rad(cpatch%corad, ico)
   call init_cohort_vars_therm(cpatch%cotherm, ico)

   return
end subroutine init_ed_cohort_vars
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
!      This subroutine initialise a bunch of patch-level variables.  This should be called !
! whenever a group of new patches is created.                                              !
!------------------------------------------------------------------------------------------!
subroutine init_ed_patch_vars(csite,ip1,ip2,lsl)
   use ed_state_vars  , only : sitetype             ! ! structure
   use ed_max_dims    , only : n_pft                ! ! intent(in)
   use grid_coms      , only : nzs                  & ! intent(in)
                             , nzg                  ! ! intent(in)
   use soil_coms      , only : slz                  ! ! intent(in)
   use canopy_air_coms, only : veg_height_min       & ! intent(in)
                             , minimum_canopy_depth ! ! intent(in)
   use ed_misc_coms   , only : imoutput             & ! intent(in)
                             , idoutput             & ! intent(in)
                             , iqoutput             ! ! intent(in)
   implicit none
   !----- Arguments. ----------------------------------------------------------------------!
   type(sitetype)   , target     :: csite
   integer          , intent(in) :: ip1
   integer          , intent(in) :: ip2
   integer          , intent(in) :: lsl
   !----- Local variables. ----------------------------------------------------------------!
   integer                       :: ipft
   integer                       :: ncohorts
   integer                       :: ipa
   !---------------------------------------------------------------------------------------!



   do ipa = ip1,ip2
      !------ Make sure photosynthesis will be calculated at the first time. --------------!
      do ipft = 1,n_pft
         csite%old_stoma_data_max(ipft,ipa)%recalc = 1
      end do
   end do


   !------ Initialise soil state variables. -----------------------------------------------!
   csite%soil_water(1:nzg,ip1:ip2)     = 0.0
   csite%soil_energy(1:nzg,ip1:ip2)   = 0.0
   csite%soil_tempk(1:nzg,ip1:ip2)    = 0.0
   csite%soil_fracliq(1:nzg,ip1:ip2)  = 0.0
   csite%rootdense(1:nzg,ip1:ip2)  = 0.0

   csite%current_paw(1:nzg,ip1:ip2) = 0.
   csite%past_paw(1:nzg,1:10,ip1:ip2) = 0.

   !------ Initialize sfcwater state variables. -------------------------------------------!
   csite%sfcwater_mass(1:nzs,ip1:ip2)     = 0.0
   csite%sfcwater_energy(1:nzs,ip1:ip2)   = 0.0
   csite%sfcwater_depth(1:nzs,ip1:ip2)    = 0.0
   csite%sfcwater_tempk(1:nzs,ip1:ip2)    = 0.0
   csite%sfcwater_fracliq(1:nzs,ip1:ip2)  = 0.0
   csite%total_sfcw_depth(ip1:ip2)        = 0.0
   csite%snowfac(ip1:ip2)                 = 0.0
   csite%runoff(ip1:ip2)                  = 0.0

   csite%rshort_s(:,ip1:ip2) = 0.0
   csite%rshort_s_beam(:,ip1:ip2) = 0.0
   csite%rshort_s_diffuse(:,ip1:ip2) = 0.0
   csite%nlev_sfcwater(ip1:ip2) = 0
   
   csite%rlong_s(ip1:ip2) = 0.0
   
   csite%avg_daily_temp(ip1:ip2) = 0.0

   csite%mean_rh(ip1:ip2) = 0.0
   csite%mean_nep(ip1:ip2) = 0.0
     
   csite%A_decomp(ip1:ip2)             = 0.0
   csite%f_decomp(ip1:ip2)             = 0.0
   csite%rh(ip1:ip2)                   = 0.0
   csite%cwd_rh(ip1:ip2)               = 0.0
   csite%fuse_flag(ip1:ip2)            = 0.0
   csite%plant_ag_biomass(ip1:ip2)     = 0.0

   csite%mean_runoff(ip1:ip2) = 0.0
   csite%mean_wflux(ip1:ip2) = 0.0
   csite%mean_latflux(ip1:ip2) = 0.0
   csite%mean_qrunoff(ip1:ip2) = 0.0
   csite%mean_hflux(ip1:ip2) = 0.0
   
   csite%today_A_decomp(ip1:ip2) = 0.0
   csite%today_Af_decomp(ip1:ip2) = 0.0

   csite%par_l_max        (ip1:ip2) = 0.0
   csite%par_l_beam_max   (ip1:ip2) = 0.0
   csite%par_l_diffuse_max(ip1:ip2) = 0.0

   csite%repro(1:n_pft,ip1:ip2) = 0.0
   csite%A_o_max(1:n_pft,ip1:ip2) = 0.0
   csite%A_c_max(1:n_pft,ip1:ip2) = 0.0

   csite%htry(ip1:ip2) = 1.0
   

   csite%co2budget_gpp(ip1:ip2)            = 0.0
   csite%co2budget_gpp_dbh(:,ip1:ip2)      = 0.0
   csite%co2budget_rh(ip1:ip2)             = 0.0
   csite%co2budget_plresp(ip1:ip2)         = 0.0
   csite%co2budget_initialstorage(ip1:ip2) = 0.0
   csite%co2budget_loss2atm(ip1:ip2)       = 0.0
   csite%co2budget_denseffect(ip1:ip2)     = 0.0
   csite%co2budget_residual(ip1:ip2)       = 0.0
   csite%wbudget_precipgain(ip1:ip2)       = 0.0
   csite%wbudget_loss2atm(ip1:ip2)         = 0.0
   csite%wbudget_loss2runoff(ip1:ip2)      = 0.0
   csite%wbudget_loss2drainage(ip1:ip2)    = 0.0
   csite%wbudget_denseffect(ip1:ip2)       = 0.0
   csite%wbudget_initialstorage(ip1:ip2)   = 0.0
   csite%wbudget_residual(ip1:ip2)         = 0.0
   csite%ebudget_precipgain(ip1:ip2)       = 0.0
   csite%ebudget_netrad(ip1:ip2)           = 0.0
   csite%ebudget_loss2atm(ip1:ip2)         = 0.0
   csite%ebudget_loss2runoff(ip1:ip2)      = 0.0
   csite%ebudget_loss2drainage(ip1:ip2)    = 0.0
   csite%ebudget_denseffect(ip1:ip2)       = 0.0
   csite%ebudget_initialstorage(ip1:ip2)   = 0.0
   csite%ebudget_residual(ip1:ip2)         = 0.0



   if (idoutput > 0 .or. imoutput > 0 .or. iqoutput > 0) then
      csite%dmean_A_decomp        (ip1:ip2) = 0.0
      csite%dmean_Af_decomp       (ip1:ip2) = 0.0
      csite%dmean_rh              (ip1:ip2) = 0.0
      csite%dmean_co2_residual    (ip1:ip2) = 0.0
      csite%dmean_energy_residual (ip1:ip2) = 0.0
      csite%dmean_water_residual  (ip1:ip2) = 0.0
      csite%dmean_lambda_light    (ip1:ip2) = 0.0
      csite%dmean_rk4step         (ip1:ip2) = 0.0
      csite%dmean_albedo          (ip1:ip2) = 0.0
      csite%dmean_albedo_beam     (ip1:ip2) = 0.0
      csite%dmean_albedo_diffuse  (ip1:ip2) = 0.0
   end if

   if (imoutput > 0 .or. iqoutput > 0) then
      csite%mmean_A_decomp        (ip1:ip2) = 0.0
      csite%mmean_Af_decomp       (ip1:ip2) = 0.0
      csite%mmean_rh              (ip1:ip2) = 0.0
      csite%mmean_co2_residual    (ip1:ip2) = 0.0
      csite%mmean_energy_residual (ip1:ip2) = 0.0
      csite%mmean_water_residual  (ip1:ip2) = 0.0
      csite%mmean_lambda_light    (ip1:ip2) = 0.0
      csite%mmean_rk4step         (ip1:ip2) = 0.0
      csite%mmean_albedo          (ip1:ip2) = 0.0
      csite%mmean_albedo_beam     (ip1:ip2) = 0.0
      csite%mmean_albedo_diffuse  (ip1:ip2) = 0.0
   end if

   if (iqoutput > 0) then
      csite%qmean_rh              (:,ip1:ip2) = 0.0
      csite%qmean_albedo          (:,ip1:ip2) = 0.0
      csite%qmean_albedo_beam     (:,ip1:ip2) = 0.0
      csite%qmean_albedo_diffuse  (:,ip1:ip2) = 0.0
   end if

   !----------------------------------------------------------------------------------------!
   !    These variables need to be initialized here otherwise it will fail when new patches !
   ! are created.                                                                           !
   !----------------------------------------------------------------------------------------!
   csite%avg_rk4step          (ip1:ip2) = 0.0
   csite%avg_carbon_ac        (ip1:ip2) = 0.0
   csite%avg_vapor_lc         (ip1:ip2) = 0.0
   csite%avg_vapor_wc         (ip1:ip2) = 0.0
   csite%avg_dew_cg           (ip1:ip2) = 0.0
   csite%avg_vapor_gc         (ip1:ip2) = 0.0
   csite%avg_wshed_vg         (ip1:ip2) = 0.0
   csite%avg_intercepted      (ip1:ip2) = 0.0
   csite%avg_throughfall      (ip1:ip2) = 0.0
   csite%avg_vapor_ac         (ip1:ip2) = 0.0
   csite%avg_transp           (ip1:ip2) = 0.0
   csite%avg_evap             (ip1:ip2) = 0.0
   csite%avg_rshort_gnd       (ip1:ip2) = 0.0
   csite%avg_rlong_gnd        (ip1:ip2) = 0.0
   csite%avg_runoff           (ip1:ip2) = 0.0
   csite%avg_drainage         (ip1:ip2) = 0.0
   csite%avg_drainage_heat    (ip1:ip2) = 0.0
   csite%aux                  (ip1:ip2) = 0.0
   csite%avg_sensible_lc      (ip1:ip2) = 0.0
   csite%avg_sensible_wc      (ip1:ip2) = 0.0
   csite%avg_qwshed_vg        (ip1:ip2) = 0.0
   csite%avg_qintercepted     (ip1:ip2) = 0.0
   csite%avg_qthroughfall     (ip1:ip2) = 0.0
   csite%avg_sensible_gc      (ip1:ip2) = 0.0
   csite%avg_sensible_ac      (ip1:ip2) = 0.0
   csite%avg_runoff_heat      (ip1:ip2) = 0.0
   csite%avg_sensible_gg    (:,ip1:ip2) = 0.0
   csite%avg_smoist_gg      (:,ip1:ip2) = 0.0
   csite%avg_transloss      (:,ip1:ip2) = 0.0
   csite%aux_s              (:,ip1:ip2) = 0.0
   csite%avg_available_water  (ip1:ip2) = 0.0
   csite%avg_leaf_energy      (ip1:ip2) = 0.0 
   csite%avg_leaf_temp        (ip1:ip2) = 0.0 
   csite%avg_leaf_hcap        (ip1:ip2) = 0.0 
   csite%avg_leaf_fliq        (ip1:ip2) = 0.0 
   csite%avg_leaf_water       (ip1:ip2) = 0.0 
   csite%avg_wood_energy      (ip1:ip2) = 0.0 
   csite%avg_wood_temp        (ip1:ip2) = 0.0 
   csite%avg_wood_hcap        (ip1:ip2) = 0.0 
   csite%avg_wood_fliq        (ip1:ip2) = 0.0 
   csite%avg_wood_water       (ip1:ip2) = 0.0 

   csite%rshort_g             (ip1:ip2) = 0.0
   csite%rshort_g_beam        (ip1:ip2) = 0.0
   csite%rshort_g_diffuse     (ip1:ip2) = 0.0
   csite%rlong_g              (ip1:ip2) = 0.0
   csite%rlong_g_surf         (ip1:ip2) = 0.0
   csite%rlong_g_incid        (ip1:ip2) = 0.0
   csite%rlong_s              (ip1:ip2) = 0.0
   csite%rlong_s_surf         (ip1:ip2) = 0.0
   csite%rlong_s_incid        (ip1:ip2) = 0.0
   csite%albedo               (ip1:ip2) = 0.0
   csite%albedo_beam          (ip1:ip2) = 0.0
   csite%albedo_diffuse       (ip1:ip2) = 0.0
   csite%rlongup              (ip1:ip2) = 0.0
   csite%rlong_albedo         (ip1:ip2) = 0.0
   csite%lambda_light         (ip1:ip2) = 0.0

   csite%fsc_in                      (ip1:ip2) = 0.0
   csite%ssc_in                      (ip1:ip2) = 0.0
   csite%ssl_in                      (ip1:ip2) = 0.0
   csite%fsn_in                      (ip1:ip2) = 0.0


   csite%fsp_in                      (ip1:ip2) = 0.0
   csite%stsp_in                      (ip1:ip2) = 0.0


   csite%total_plant_P_uptake (ip1:ip2) = 0.0


   csite%total_plant_nitrogen_uptake (ip1:ip2) = 0.0

   csite%mineralized_N_loss          (ip1:ip2) = 0.0
   csite%mineralized_N_input         (ip1:ip2) = 0.0
   
   csite%watertable(ip1:ip2)                  = slz(lsl)
   csite%ustar (ip1:ip2) = 0.0
   csite%tstar (ip1:ip2) = 0.0
   csite%qstar (ip1:ip2) = 0.0
   csite%cstar (ip1:ip2) = 0.0
   csite%zeta  (ip1:ip2) = 0.0
   csite%ribulk(ip1:ip2) = 0.0
   csite%upwp  (ip1:ip2) = 0.0
   csite%tpwp  (ip1:ip2) = 0.0
   csite%qpwp  (ip1:ip2) = 0.0
   csite%cpwp  (ip1:ip2) = 0.0
   csite%wpwp  (ip1:ip2) = 0.0

   csite%can_theiv   (ip1:ip2) = 0.0
   csite%can_temp    (ip1:ip2) = 0.0
   csite%can_rhos    (ip1:ip2) = 0.0
   csite%can_depth   (ip1:ip2) = 0.0
   csite%opencan_frac(ip1:ip2) = 0.0
   csite%ground_shv  (ip1:ip2) = 0.0
   csite%ground_ssh  (ip1:ip2) = 0.0
   csite%ground_temp (ip1:ip2) = 0.0
   csite%ground_fliq (ip1:ip2) = 0.0

   csite%ggbare(ip1:ip2) = 0.0
   csite%ggveg (ip1:ip2) = 0.0
   csite%ggnet (ip1:ip2) = 0.0
   csite%ggsoil(ip1:ip2) = 0.0

   csite%old_stoma_data_max(:,ip1:ip2)%recalc = 1
   csite%old_stoma_data_max(:,ip1:ip2)%T_L = 0.0
   csite%old_stoma_data_max(:,ip1:ip2)%e_A              = 0.0
   csite%old_stoma_data_max(:,ip1:ip2)%PAR              = 0.0
   csite%old_stoma_data_max(:,ip1:ip2)%rb_factor        = 0.0
   csite%old_stoma_data_max(:,ip1:ip2)%prss             = 0.0
   csite%old_stoma_data_max(:,ip1:ip2)%phenology_factor = 0.0
   csite%old_stoma_data_max(:,ip1:ip2)%gsw_open         = 0.0
   csite%old_stoma_data_max(:,ip1:ip2)%ilimit           = 0
   csite%old_stoma_data_max(:,ip1:ip2)%T_L_residual     = 0.0
   csite%old_stoma_data_max(:,ip1:ip2)%e_a_residual     = 0.0
   csite%old_stoma_data_max(:,ip1:ip2)%par_residual     = 0.0
   csite%old_stoma_data_max(:,ip1:ip2)%rb_residual      = 0.0
   csite%old_stoma_data_max(:,ip1:ip2)%leaf_residual    = 0.0
   csite%old_stoma_data_max(:,ip1:ip2)%gsw_residual     = 0.0
   
   
   csite%old_stoma_vector_max(:,:,ip1:ip2) = 0.
   csite%old_stoma_vector_max(1,:,ip1:ip2) =                                               &
                                         real(csite%old_stoma_data_max(:,ip1:ip2)%recalc)


   ncohorts = 0
   do ipa=1,csite%npatches
      ncohorts = ncohorts + csite%patch(ipa)%ncohorts
   enddo

   csite%cohort_count = ncohorts

   return
end subroutine init_ed_patch_vars
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
!     This sub-routine initialises some site-level variables.                              !
!------------------------------------------------------------------------------------------!
subroutine init_ed_site_vars(cpoly, lat)
   use ed_state_vars, only : polygontype      ! ! intent(in)
   use ed_max_dims  , only : n_pft            & ! intent(in)
                           , n_dbh            & ! intent(in)
                           , n_dist_types     ! ! intent(in)
   use pft_coms     , only : agri_stock       & ! intent(in)
                           , plantation_stock ! ! intent(in)
   use grid_coms    , only : nzs              & ! intent(in)
                           , nzg              ! ! intent(in)
   implicit none
   !----- Arguments. ----------------------------------------------------------------------!
   type(polygontype), target     :: cpoly
   real             , intent(in) :: lat
   !----- External functions. -------------------------------------------------------------!
   integer          , external   :: julday
   !---------------------------------------------------------------------------------------!

   cpoly%basal_area       (1:n_pft, 1:n_dbh, :) = 0.0
   cpoly%basal_area_growth(1:n_pft, 1:n_dbh, :) = 0.0
   cpoly%basal_area_mort  (1:n_pft, 1:n_dbh, :) = 0.0
   cpoly%basal_area_cut   (1:n_pft, 1:n_dbh, :) = 0.0

   cpoly%agb              (1:n_pft, 1:n_dbh, :) = 0.0
   cpoly%agb_growth       (1:n_pft, 1:n_dbh, :) = 0.0
   cpoly%agb_mort         (1:n_pft, 1:n_dbh, :) = 0.0
   cpoly%agb_cut          (1:n_pft, 1:n_dbh, :) = 0.0

   cpoly%green_leaf_factor(1:n_pft,:) = 1.0
   cpoly%leaf_aging_factor(1:n_pft,:) = 1.0

   !---------------------------------------------------------------------------------------!
   !      Initialise the minimum monthly temperature with a very large value, this is      !
   ! going to be reduced as the canopy temperature is updated.                             !
   !---------------------------------------------------------------------------------------!
   cpoly%min_monthly_temp(:) = huge(1.)
   !---------------------------------------------------------------------------------------!

   cpoly%lambda_fire       (1:12,:)                           = 0.0

   cpoly%disturbance_memory(1:n_dist_types, 1:n_dist_types,:) = 0.0
   cpoly%disturbance_rates (1:n_dist_types, 1:n_dist_types,:) = 0.0

   cpoly%agri_stocking_density(:)                             = 10.0

   !---------------------------------------------------------------------------------------!
   ! (KIM)                                                                                 !
   !     - anyway, this part should be more elaborate for the case                         !
   !     - that we have different crops/pastures.                                          !
   !  It's now defined in ED2IN, but it assumes only one PFT. It is probably not the       !
   !  ideal solution for regional runs...                                                  !
   !---------------------------------------------------------------------------------------!
   cpoly%agri_stocking_pft(:)       = agri_stock
   cpoly%plantation_stocking_pft(:) = plantation_stock

   cpoly%plantation_stocking_density(:) = 4.0

   cpoly%primary_harvest_memory(:)   = 0.0
   cpoly%secondary_harvest_memory(:) = 0.0
  
   cpoly%rad_avg(:) = 200.0
  
  
   return
end subroutine init_ed_site_vars
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
subroutine init_ed_poly_vars(cgrid)
  
   use ed_state_vars, only : edtype      & ! structure
                           , polygontype & ! structure
                           , sitetype    ! ! structure
   use ed_misc_coms , only : dtlsm       ! ! intent(in)
   use consts_coms  , only : day_sec     ! ! intent(in)
   implicit none
   !----- Arguments. ----------------------------------------------------------------------!  
   type(edtype)     , target  :: cgrid
   !----- Local variables. ----------------------------------------------------------------!
   type(polygontype), pointer :: cpoly
   type(sitetype)   , pointer :: csite
   integer                    :: ipy
   integer                    :: isi
   integer                    :: ipa
   real                       :: soil_C
   real                       :: soil_N
   real                       :: veg_C
   real                       :: veg_N
   real                       :: patchload
   !---------------------------------------------------------------------------------------!


   !---------------------------------------------------------------------------------------!
   !    WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!   !
   !---------------------------------------------------------------------------------------!
   !     Please, don't initialise polygon-level (cgrid) variables outside polyloop.  This  !
   ! works in off-line runs, but it causes memory leaks (and crashes) in the coupled runs  !
   ! over the ocean, where cgrid%npolygons can be 0 if one of the subdomains falls         !
   ! entirely over the ocean.  Thanks!                                                     !
   !---------------------------------------------------------------------------------------!
   ! cgrid%blah = 0. !<<--- This is a bad way of doing, look inside the loop for the
   !                 !      safe way of initialising the variable.
   !---------------------------------------------------------------------------------------!


   !---------------------------------------------------------------------------------------!
   !      Define a nominal initial value of patch workload.  Normally we start with the    !
   ! RK4 time step to be 1 second, so each patch will contribute with 86400 time steps per !
   ! day.                                                                                  !
   !---------------------------------------------------------------------------------------!
   patchload = day_sec

   do ipy = 1,cgrid%npolygons

      !------------------------------------------------------------------------------------!
      !     This is the right and safe place to initialise polygon-level (cgrid) vari-     !
      ! ables, so in case npolygons is zero this will not cause memory leaks.  I know,     !
      ! this never happens in off-line runs, but it is quite common in coupled runs...     !
      ! Whenever one of the nodes receives a sub-domain where all the points are over the  !
      ! ocean, ED will not assign any polygon in that sub-domain, which means that that    !
      ! node will have 0 polygons, and the variables cannot be allocated.  If you try to   !
      ! access the polygon level variable outside the loop, then the model crashes due to  !
      ! segmentation violation (a bad thing), whereas by putting the variables here both   !
      ! the off-line model and the coupled runs will work, because this loop will be       !
      ! skipped when there is no polygon.                                                  !
      !------------------------------------------------------------------------------------!
      cgrid%mean_precip (ipy)  = 0.0
      cgrid%mean_qprecip(ipy)  = 0.0
      cgrid%mean_netrad (ipy)  = 0.0

      call compute_C_and_N_storage(cgrid,ipy,soil_C, soil_N, veg_C, veg_N)
      cgrid%cbudget_initialstorage(ipy) = soil_C + veg_C
      cgrid%nbudget_initialstorage(ipy) = soil_N + veg_N
      cgrid%cbudget_nep(ipy) = 0.0

      !----- Count how many patches we have, and add to the workload. ---------------------!
      cgrid%workload(:,ipy)  = 0.0
      cpoly => cgrid%polygon(ipy)
      do isi = 1, cpoly%nsites
         csite => cpoly%site(isi)
         cgrid%workload(1:12,ipy) = cgrid%workload(1:12,ipy)                               &
                                  + real(csite%npatches) * patchload
      end do
   end do

   return
end subroutine init_ed_poly_vars
!==========================================================================================!
!==========================================================================================!






!==========================================================================================!
!==========================================================================================!
!     This subroutine will assign the values of some diagnostic variables, such as soil    !
! and temporary layer temperature and liquid fraction, and the surface properties.         !
!------------------------------------------------------------------------------------------!
subroutine new_patch_sfc_props(csite,ipa,mzg,mzs,ntext_soil)
   use ed_state_vars , only : sitetype           & ! structure
                            , patchtype          ! ! structure
   use soil_coms     , only : soil               & ! intent(in), look-up table
                            , slz                & ! intent(in)
                            , tiny_sfcwater_mass ! ! intent(in)
   use consts_coms   , only : wdns               ! ! intent(in)
   use therm_lib     , only : qwtk               & ! subroutine
                            , qtk                ! ! subroutine
   use ed_therm_lib  , only : ed_grndvap         ! ! subroutine
   implicit none
   !----- Arguments -----------------------------------------------------------------------!
   type(sitetype)                 , target     :: csite      ! Current site
   integer                        , intent(in) :: ipa        ! Number of the current patch
   integer                        , intent(in) :: mzg        ! Number of soil layers
   integer                        , intent(in) :: mzs        ! Number of sfc. water layers
   integer        , dimension(mzg), intent(in) :: ntext_soil ! Soil texture
   !----- Local variables -----------------------------------------------------------------!
   type(patchtype)                , pointer    :: cpatch     ! Current patch
   integer                                     :: k          ! Layer counter
   integer                                     :: ico        ! Cohort counter
   integer                                     :: nsoil      ! Alias for soil texture class
   !---------------------------------------------------------------------------------------!
  
   !----- Finding soil temperature and liquid water fraction. -----------------------------!
   do k = 1, mzg
      nsoil = ntext_soil(k)
      call qwtk(csite%soil_energy(k,ipa), csite%soil_water(k,ipa)*wdns                     &
                ,soil(nsoil)%slcpd, csite%soil_tempk(k,ipa), csite%soil_fracliq(k,ipa))
   end do
   !---------------------------------------------------------------------------------------! 



   !---------------------------------------------------------------------------------------! 
   !   Determine the number of temporary snow/surface water layers.  This is done by       !
   ! checking the mass.  In case there is a layer, we convert sfcwater_energy from J/m2 to !
   ! J/kg, and compute the temperature and liquid fraction.                                !
   !---------------------------------------------------------------------------------------! 
   csite%nlev_sfcwater(ipa) = 0
   snowloop: do k=1,mzs
      !----- Leave the loop if there is not enough mass in this layer... ------------------!
      if (csite%sfcwater_mass(k,ipa) <= tiny_sfcwater_mass)  exit snowloop
      csite%nlev_sfcwater(ipa) = k
      csite%sfcwater_energy(k,ipa) = csite%sfcwater_energy(k,ipa)                          &
                                   / csite%sfcwater_mass(k,ipa)
      call qtk(csite%sfcwater_energy(k,ipa),csite%sfcwater_tempk(k,ipa)                    &
              ,csite%sfcwater_fracliq(k,ipa))
   end do snowloop
   !---------------------------------------------------------------------------------------!
   !     Now, just to be safe, we will assign zeroes to layers above.                      !
   !---------------------------------------------------------------------------------------!
   do k=csite%nlev_sfcwater(ipa)+1,mzs
      csite%sfcwater_mass(k,ipa)   = 0.
      csite%sfcwater_energy(k,ipa) = 0.
      csite%sfcwater_depth(k,ipa)  = 0.
      if (k == 1) then
         csite%sfcwater_tempk(k,ipa)   = csite%soil_tempk(mzg,ipa)
         csite%sfcwater_fracliq(k,ipa) = csite%soil_fracliq(mzg,ipa) 
      else
         csite%sfcwater_tempk(k,ipa)   = csite%sfcwater_tempk(k-1,ipa)
         csite%sfcwater_fracliq(k,ipa) = csite%sfcwater_fracliq(k-1,ipa)
      end if
   end do
   !---------------------------------------------------------------------------------------! 


   
   !----- Now we can compute the surface properties. --------------------------------------!
   k=max(1,csite%nlev_sfcwater(ipa))
   call ed_grndvap(csite%nlev_sfcwater(ipa),ntext_soil(mzg)                                &
                  ,csite%soil_water(mzg,ipa),csite%soil_tempk(mzg,ipa)                     &
                  ,csite%soil_fracliq(mzg,ipa),csite%sfcwater_tempk(k,ipa)                 &
                  ,csite%sfcwater_fracliq(k,ipa),csite%can_prss(ipa)                       &
                  ,csite%can_shv(ipa),csite%ground_shv(ipa),csite%ground_ssh(ipa)          &
                  ,csite%ground_temp(ipa),csite%ground_fliq(ipa),csite%ggsoil(ipa))
   !---------------------------------------------------------------------------------------! 

   return
end subroutine new_patch_sfc_props
!==========================================================================================!
!==========================================================================================!
