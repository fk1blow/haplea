import { RouterModule, Routes } from '@angular/router';

import { NewEntryRouteComponent } from './new-entry-route/new-entry-route.component';
import { NgModule } from '@angular/core';
import { DashboardPageComponent } from './dashboard-page/dashboard-page.component';

const routes: Routes = [
  { path: 'expense/new/:date', component: NewEntryRouteComponent },
  { path: '', component: DashboardPageComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
