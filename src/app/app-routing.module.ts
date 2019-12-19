import { RouterModule, Routes } from '@angular/router';

import { NewEntryRouteComponent } from './new-entry-route/new-entry-route.component';
import { NgModule } from '@angular/core';

const routes: Routes = [
  { path: 'expense/new/:date', component: NewEntryRouteComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
