/**
 * Created by mlandels on 2021-05-27.
 */
// Apex
import toggleFavourite from '@salesforce/apex/KHC_ResourceLibraryCtrl.toggleFavourite';

export async function toggleReferralRecordFavourite (currentAccountId, isFavourited, knowledgeArticleId, isKnowledgeFeatured) {
    return new Promise(async (resolve, reject) =>{
        await toggleFavourite({
            currentAccountId : currentAccountId,
            isFavourited : isFavourited,
            knowledgeArticleId : knowledgeArticleId,
            isKnowledgeFeatured : isKnowledgeFeatured
        }).then(result=>{
            resolve(result);
        }).catch(error=>{
            reject(error);
        })
    });
}