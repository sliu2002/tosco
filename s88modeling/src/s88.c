/*  S88modeling - Seismic modeler by rays theory
 *  Copyright (C) 2009 Ricardo Biloti <biloti@ime.unicamp.br>
 * 
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 * 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 * 
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdlib.h>
#include <unistd.h>
#include <glib.h>
#include <glib/gstdio.h>

#include "s88.h"

void write_s88_config(FILE *fp, struct s88 *p);
void write_synt_config(FILE *fp, struct s88 *p);
void synt2bin (struct s88 *p);

void write_double_vector(FILE *fp, gdouble *vec, gint N, gchar *format, gint auxin, gint max);
void write_int_vector(FILE *fp, gint *vec, gint N, gchar *format, gint auxin, gint max);
GString* make_unique_filename(const gchar * template);

void s88_run(struct s88 *p)
{
        FILE *fp;
        GString *cmd1;
        GString *cmd2;
        GString *fname1;
        GString *fname2;
        GString *newname;
        gint ishot;

        if (!p->dryrun){
                fname1 = make_unique_filename ("XXXXXX.ray");
                fname2 = make_unique_filename ("XXXXXX.sis");
                cmd1 = g_string_new (NULL);
                cmd2 = g_string_new (NULL);
                g_string_printf (cmd1, "%s >/dev/null <<EOF\n"
                                 "1\n%s\n"
                                 "2\nseis.out\n"
                                 "7\nlu1.dat\n"
                                 "8\nlu2.dat\n"
                                 "0\n0\nEOF\n", p->spath, fname1->str);
                
                g_string_printf (cmd2, "%s >/dev/null <<EOF\n"
                                 "1\n%s\n"
                                 "2\nsynt.out\n"
                                 "3\nlu2.dat\n"
                                 "4\nlu3.dat\n"
                                 "0\n0\nEOF\n", p->sypath, fname2->str);
                
                fp = fopen (fname2->str, "w");
                write_synt_config (fp, p);
                fclose (fp);
        }
        
        if (p->debug){
                fprintf (stderr, "\nSyntpl config:\n");
                write_synt_config (stderr, p);
                fprintf (stderr, "\n");
        }
                
        p->zsour = p->sz;
        for (ishot=0; ishot<p->nshots; ishot++){

                newname = g_string_new(NULL);
                
                p->xsour = p->sxmin + p->sxstep * ishot;
                p->rmin  = p->xsour + p->rxmin;
                 
                if (p->verbose)
                        fprintf (stderr, "Modeling for source at %f: ", p->xsour);
                if (p->debug){
                        fprintf (stderr, "\nSeis config:\n");
                        write_s88_config (stderr, p);
                        fprintf (stderr, "\n");
                }
                
                if (!p->dryrun){
                        fp = fopen (fname1->str, "w");
                        write_s88_config (fp, p);
                        fclose (fp);

                        if (!system (cmd1->str)){
                                if (!system (cmd2->str)){
                                        synt2bin(p);
                                        if (p->verbose) fprintf(stderr,"done\n");
                                }
                                else{
                                        fprintf(stderr, "\nsyntpl with problem\n");
                                }
                        }
                        else{
                                fprintf(stderr, "\nseis with problem\n");
                        }

                        if (p->showrays){
                                g_string_printf(newname, "lu1-%04i.dat", ishot+1);
                                g_rename("lu1.dat", newname->str);
                        }
                }

        }
        g_string_free(newname, TRUE);

        if (!p->dryrun){
                if (!p->debug){
                        g_unlink (fname1->str);
                        g_unlink (fname2->str);
                        if (!p->showrays){
                                g_unlink ("lu1.dat");
                        }
                        g_unlink ("lu2.dat");
                        g_unlink ("lu3.dat");
                        g_unlink ("seis.out");
                        g_unlink ("synt.out");
                        g_unlink ("fort.10");
                        g_unlink ("curv.dat");
                        g_unlink ("qp.dat");
                }

                g_string_free (fname1, TRUE);
                g_string_free (fname2, TRUE);
                g_string_free (cmd1, TRUE);
                g_string_free (cmd2, TRUE);
        }
}


void write_s88_config(FILE *fp, struct s88 *p)
{
        gint ii, jj, aux;
        gdouble  vmin, vmax, bmin, bmax, bleft, bright;
        
        bmin = p->z[0][0];
        bmax = p->z[0][0];
        bleft = p->x[0][0];
        bright = p->x[0][0];


        // CARD 1
        fprintf (fp,"%2i%2i%2i%68s  %2i%2i\n", 0, 2, 0 , "", 0, 1);
        
        // CARD 2
        fprintf (fp,"%5i",p->nint);
        write_int_vector (fp, p->npnt, p->nint, "%5i", 1, 16);

        // CARD 3
        for (ii=0; ii<p->nint; ii++){
                aux = 0;
                for (jj=0; jj<p->npnt[ii]; jj++){
                        fprintf (fp,"%10.5f%10.5f%5i", p->x[ii][jj], p->z[ii][jj], p->iii[ii][jj]);

                        bmin = MIN(bmin, p->z[ii][jj]);
                        bmax = MAX(bmax, p->z[ii][jj]);
                        bleft = MIN(bleft, p->x[ii][jj]);
                        bright = MAX(bright, p->x[ii][jj]);

                        aux++;
                        if (aux == 3){
                                fprintf (fp,"\n");
                                aux =0;
                        }
                }
                if (aux!=0)
                        fprintf (fp,"\n");
        }

        // CARD 4 (MM=1 only)
        write_double_vector (fp, p->v1, p->nint-1, "%10.5f", 0, 8);
        write_double_vector (fp, p->v2, p->nint-1, "%10.5f", 0, 8);
	      
        // CARD 5
        fprintf(fp, "%5i", (p->nro ? 1 : 0));

        vmin = p->v1[0];
        vmax = p->v2[0];

        aux = 1;
        for (ii=0; ii<p->nint-1; ii++){
                fprintf (fp, "%5i", 0);  /* nvs = 0: p-wave velocities */
                aux ++;
                
                if (aux == 16){
                        fprintf (fp,"\n");
                        aux = 0;
                }

                vmin = MIN(vmin, p->v1[ii]);
                vmin = MIN(vmin, p->v2[ii]);
                vmin = MIN(vmin, p->v1[ii]);

                vmax = MAX(vmax, p->v1[ii]);
                vmax = MAX(vmax, p->v2[ii]);

        }

        fprintf(fp, "%5i\n", 0); /* NABS = 0: no absortion */
  
        // CARD 6A
        if (p->nro){
                aux = 0;
                for (ii=0; ii<p->nint-1; ii++){
                        fprintf (fp, "%10.5f%10.5f", p->rho1[ii], p->rho2[ii]);
                        aux++;
                        
                        if (aux == 4){
                                fprintf(fp,"\n");
                                aux = 0;
                        }
                }
                if (aux != 0)
                        fprintf(fp,"\n");
        }

        // CARD 6B
        /* Not present, since nabs = 0 */

        // CARD 7
        write_double_vector (fp, p->ptos, p->nint-1, "%10.5f", 0, 8);

        // CARD 8
        fprintf (fp, "%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f\n",
                 vmin, vmax, bmin, bmax, bleft, bright);

        // CARD 9
        fprintf (fp, "%3i%3i%3i%3i%3i",
                1, p->mep, 0, p->mdim, p->method);

        fprintf (fp, "%3i%3i%3i%3i%3i%3i",
                 0, 0, 0, 0, 0, 0);

        fprintf (fp, "%3i%3i%3i%3i%3i%3i", 1, 1, 0, 1, 7, 8);

        fprintf (fp, "%3i%3i%3i\n", 0, 0, 0);

        // CARD 10 (MEP > 0)
        fprintf (fp, "%10.5f%10.5f%10.5f\n", p->rmin, p->rxstep, 0.0);

        // CARD 11
        fprintf (fp, "%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f\n",
                 p->xsour, p->zsour, p->tsour, p->reps, p->reps1, bleft, bright);

        // CARD 12 
        fprintf (fp, "%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f\n",
                p->dtint, p->amin1, p->astep1, p->amax1, p->amin2, p->astep2, p->amax2, p->ac);


        // CARD 13 (Wave codes)
        // FIX-ME: Se a linha for muito comprida, tem que ser cortada (24I3)
        if (p->ibp)
        {
                gint ii, jj;

                for (ii=1; ii<= p->nint-2; ii++){
                        fprintf(fp, "%3i%3i", 1, 2*ii);
                        for (jj=1; jj<=ii; jj++)
                                fprintf(fp, "%3i", jj);
                        for (jj=ii; jj>=1; jj--)
                                fprintf(fp, "%3i", jj);
                        fprintf(fp, "\n");
                }
                
                /* Also converted wave ? */
                if (p->ibp == 2){
                        for (ii=1; ii<= p->nint-2; ii++){
                                fprintf(fp, "%3i%3i", 1, 2*ii);
                                for (jj=1; jj<=ii; jj++)
                                        fprintf(fp, "%3i",  jj);
                                for (jj=ii; jj>=1; jj--)
                                        fprintf(fp, "%3i", -jj);
                                fprintf(fp, "\n");
                        }
                }                
        }

        if (p->ibs)
        {
                gint ii, jj;
                

                for (ii=1; ii<= p->nint-2; ii++){
                        fprintf(fp, "%3i%3i", 1, 2*ii);
                        for (jj=1; jj<=ii; jj++)
                                fprintf(fp, "%3i", -jj);
                        for (jj=ii; jj>=1; jj--)
                                fprintf(fp, "%3i", -jj);
                        fprintf(fp, "\n");
                }

                /* Also converted wave ? */
                if (p->ibs == 2){
                        for (ii=1; ii<= p->nint-2; ii++){
                                fprintf(fp, "%3i%3i", 1, 2*ii);
                                for (jj=1; jj<=ii; jj++)
                                        fprintf(fp, "%3i", -jj);
                                for (jj=ii; jj>=1; jj--)
                                        fprintf(fp, "%3i",  jj);
                                fprintf(fp, "\n");
                        }
                }
        }
        fprintf(fp, "\n");


        // CARD 9
        fprintf(fp, "%3i%3i%3i%3i%3i",
                0, p->mep, 0, p->mdim, p->method);

        fprintf (fp, "%3i%3i%3i%3i%3i%3i",
                 0, 0, 0, 0, 0, 0);

        fprintf (fp, "%3i%3i%3i%3i%3i%3i", 0, 1, 0, 1, 7, 8);

        fprintf (fp, "%3i%3i%3i\n", 0, 0, 0);

        fflush(fp);

}

void write_synt_config(FILE *fp, struct s88 *p)
{

        // CARD 1
        fprintf (fp,"%3i%3i%3i%3i%3i\n", 2, 3, 1, 7, 0);
        
        // CARD 2
        fprintf (fp,"%3i%3i%3i%3i%3i%3i%3i\n", 0, 0, 0, 0, 0, 0, 3);


        // CARD 3
        fprintf(fp, "%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f\n",
                p->tmin, p->dt, p->tmax, p->freq, p->gamma, p->psi, 8.0, 0.0);
  
        // CARD 7
        fprintf (fp, "%5i%5i%5i%5i%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f\n",
                 (p->implos ? -1 : 1), 0, 0, 0, p->mag, 0.0, 0.0, 0.0, 0.0, 0.0);

        fprintf (fp,"%3i%3i%3i%3i%3i\n", 0, 0, 0, 0, 0);
        fprintf (fp, "%3i\n", 0);

        fflush(fp);
}

/************************************************************/

void write_double_vector(FILE *fp, gdouble *vec, gint N, gchar *format, gint auxin, gint max)
{
        gint ii, aux;
        
        aux = auxin;
        
        for (ii=0; ii<N; ii++){
                fprintf (fp, format, vec[ii]);
                aux++;
                
                if (aux == max){
                        fprintf(fp, "\n");
                        aux = 0;
                }
        }
        
        if (aux != 0)
                fprintf(fp,"\n");
} 

/************************************************************/

void write_int_vector(FILE *fp, gint *vec, gint N, gchar *format, gint auxin, gint max)
{
        gint ii, aux;
        
        aux = auxin;
        
        for (ii=0; ii<N; ii++){
                fprintf (fp, format, vec[ii]);
                aux++;
                
                if (aux == max){
                        fprintf(fp, "\n");
                        aux = 0;
                }
        }
        
        if (aux != 0)
                fprintf(fp,"\n");
}

GString *
make_unique_filename(const gchar * template)
{
	GString *	path;

	/* assembly file path */
	path = g_string_new(NULL);
	g_string_printf(path, "%s", template);

	/* create a temporary file. */
	close(g_mkstemp(path->str));

	return path;
}



void synt2bin (struct s88 *p)
{

        FILE *fp;
        gint i, npts, ndst;
        gfloat tmin, dt, dist, rstep;
        gint bytes;
        size_t nwritten = 0;
        size_t aux;
        static gfloat *samples = NULL;

        if ((fp = fopen ("fort.10", "rb")) == NULL)
                goto out;

        if (fread(&bytes, sizeof(gint),   1, fp) < 1) goto out;
        if (fread(&npts,  sizeof(gint),   1, fp) < 1) goto out;
        if (fread(&tmin,  sizeof(gfloat), 1, fp) < 1) goto out;
        if (fread(&dt  ,  sizeof(gfloat), 1, fp) < 1) goto out;
        if (fread(&ndst,  sizeof(gint),   1, fp) < 1) goto out;
        if (fread(&dist,  sizeof(gfloat), 1, fp) < 1) goto out;
        if (fread(&rstep, sizeof(gfloat), 1, fp) < 1) goto out;

        if (p->debug){
                fprintf(stderr, "\nbytes = %i\n", bytes);
                fprintf(stderr, "npts  = %i\n", npts);
                fprintf(stderr, "tmin  = %f\n", tmin);
                fprintf(stderr, "dt    = %f\n", dt);
                fprintf(stderr, "ndst  = %i\n", ndst);
                fprintf(stderr, "dist  = %f\n", dist);
                fprintf(stderr, "rstep = %f\n", rstep);
        }
        
        if (fread(&bytes, sizeof(gint), 1, fp) < 1) goto out;

        if (samples == NULL)
                samples = (gfloat *) malloc (sizeof(float) * npts);
        
        for (i=0; i <ndst; i++){
                if (fread(&bytes, sizeof(gint), 1, fp) < 1) goto out;
                
                if (fread(samples, sizeof(gfloat), npts, fp) < npts) goto out;
                nwritten += fwrite(samples, sizeof(gfloat), npts, stdout);

                if (fread(&bytes, sizeof(gint), 1, fp) < 1) goto out;
        }

        fclose(fp);

        if (p->debug){
                fprintf(stderr, "%lu floats written\n", nwritten);
        }

        return;


   out: fprintf(stderr, "Problem with syntpl output.\nAborting.\n");
        exit (EXIT_FAILURE);


}