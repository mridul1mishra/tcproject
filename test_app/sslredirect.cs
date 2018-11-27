using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Sitecore;
using Sitecore.Links;
using Sitecore.Pipelines.HttpRequest;
using Sitecore.Web;


namespace test_app
{
    public class sslredirect : HttpRequestProcessor
    {
        public override void Process(HttpRequestArgs args1)
        {
            Sitecore.Data.Items.Item item = Context.Item;
            if (item != null)
            {
                string strSecureURL = "https://";
                if (!WebUtil.GetServerUrl().Contains(strSecureURL))
                {

                    strSecureURL = WebUtil.GetServerUrl().Replace("http://", strSecureURL) +
                                   LinkManager.GetItemUrl(item);

                    WebUtil.Redirect(strSecureURL);
                }

            }

        }

        /// <summary>
        /// Redirect requested page.
        /// </summary>
        /// <param name="args">The arguments.</param>
        /// <param name="responseUrl">The response URL.</param>
        private static void Response(HttpRequestArgs args, string responseUrl)
        {
            args.Context.Response.Clear();
            args.Context.Response.StatusCode = 301;
            args.Context.Response.RedirectLocation = responseUrl;
            args.Context.Response.End();
        }

        /// Checks the acceptable page mode.
        /// </summary>
        /// <returns>Acceptable page mode - true, otherwise - false</returns>
        private static bool CheckPageMode()
        {
            return Context.PageMode.IsNormal && !Context.PageMode.IsExperienceEditor && !Context.PageMode.IsExperienceEditorEditing && !Context.PageMode.IsPreview;
        }
    }
}